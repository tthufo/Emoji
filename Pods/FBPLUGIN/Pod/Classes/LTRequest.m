//
//  LTRequest.m
//
//  Created by thanhhaitran on 3/3/15.
//  Copyright (c) 2015 libreteam. All rights reserved.
//

#import "LTRequest.h"

#import "Reachability.h"

#import "JSONKit.h"

#import "NSObject+Category.h"

static LTRequest *__sharedLTRequest = nil;

@implementation LTRequest

@synthesize deviceToken, address;

+ (LTRequest *)sharedInstance
{
    if (!__sharedLTRequest)
    {
        __sharedLTRequest = [[LTRequest alloc] init];
    }
    return __sharedLTRequest;
}

- (void)registerPush
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
#if TARGET_IPHONE_SIMULATOR
    deviceToken = @"fake-device-token";
#endif
}

- (void)didReceiveToken:(NSData *)_deviceToken
{
    deviceToken = [[[[_deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""] stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""];
}

- (void)didFailToRegisterForRemoteNotification:(NSError *)error
{
    [self alert:self.lang ? @"Attention" : @"Thông báo" message:[error localizedDescription]];
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@", userInfo);
}

- (void)initRequest
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if(!dictionary)
    {
        NSLog(@"Check your Info.plist is not right path or name");
    }
    
    if (!dictionary[@"host"])
    {
        NSLog(@"Please setup request url in Plist");
    }
    else
    {
        self.address = dictionary[@"host"];
    }
    self.lang = [dictionary responseForKey:@"lang"];
}

- (void)didInitWithUrl:(NSDictionary*)dict withCache:(RequestCache)cache andCompletion:(RequestCompletion)completion
{
    if([self getValue:dict[@"absoluteLink"]])
    {
        cache([self getValue:dict[@"absoluteLink"]]);
    }
    else
    {
        if([dict responseForKey:@"host"])
        {
            [(UIViewController*)dict[@"host"] showSVHUD: self.lang ? @"Loading" : @"Đang tải" andOption:0];
        }
    }
    if([dict responseForKey:@"overrideLoading"])
    {
        if([dict responseForKey:@"host"])
        {
            [(UIViewController*)dict[@"host"] showSVHUD: self.lang ? @"Loading" : @"Đang tải" andOption:0];
        }
    }
    
    NSURL * requestUrl = [NSURL URLWithString:dict[@"absoluteLink"]];

    NSError* error = nil;

    NSData* htmlData = [NSData dataWithContentsOfURL:requestUrl options:NSDataReadingUncached error:&error];

    if(error)
    {
        completion(nil,error,NO);
    }
    else
    {
        completion([NSString stringWithUTF8String:[htmlData bytes]],nil,YES);
        
        [self addValue:[NSString stringWithUTF8String:[htmlData bytes]] andKey:dict[@"absoluteLink"]];
    }

    [self hideSVHUD];
}

- (ASIFormDataRequest*)REQUEST
{
    return [ASIFormDataRequest requestWithURL:[NSURL URLWithString:self.address]];
}

- (ASIFormDataRequest*)SERVICE:(NSString*)X
{
    return [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.address, X]]];
}

- (ASIFormDataRequest*)didRequestInfo:(NSDictionary*)dict withCache:(RequestCache)cacheData andCompletion:(RequestCompletion)completion
{
    if(!self.address)
    {
        NSLog(@"Please setup request url in Plist");
        
        return nil;
    }
    NSMutableDictionary * data = [dict mutableCopy];
    
    data[@"completion"] = completion;
    
    data[@"cache"] = cacheData;
    
    return [self didInitRequest:data];
}

- (BOOL)didRespond:(NSMutableDictionary*)dict andHost:(UIViewController*)host
{
    //NSLog(@"+___+%@",dict);
    
    if(host)
    {
        [host hideSVHUD];
    }
    
    if(!dict)
    {
        [host alert:self.lang ? @"Attention" : @"Thông báo" message: self.lang ? @"Server error" :  @"Hệ thống đang bận"];
        
        return NO;
    }
    
    if([dict responseForKindOfClass:@"ERR_CODE" andTarget:@"0"])
    {
        if([dict responseForKey:@"checkmark"] && host)
        {
            dict[@"status"] = @(1);
            
            [self didAddCheckMark:dict andHost:host];
        }
        return YES;
    }
    
    if([dict responseForKey:@"checkmark"] && host)
    {
        dict[@"status"] = @(0);
        
        [self didAddCheckMark:dict andHost:host];
    }
    else
    {
        [self showToast:[dict responseForKey:@"ERR_CODE"] ? dict[@"ERR_MSG"] : self.lang ? @"Server error, please try again" : @"Lỗi hệ thống xảy ra, xin hãy thử lại" andPos:0];
    }
    
    return NO;
}

- (ASIFormDataRequest*)didInitRequest:(NSMutableDictionary*)dict
{
    NSMutableDictionary * post = nil;
    
    ASIFormDataRequest * request;
    
    NSString * url;
    
    if([dict responseForKey:@"method"])
    {
        if([dict responseForKey:@"absoluteLink"])
        {
            request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:dict[@"absoluteLink"]]];
        }
        else
        {
            url = [NSString stringWithFormat:@"%@?%@",dict[@"CMD_CODE"],[self returnGetUrl:dict]];
            
            request = [self SERVICE:url];
        }
        
        [request setRequestMethod:dict[@"method"]];
        
        if([self getValue: [dict responseForKey:@"absoluteLink"] ? dict[@"absoluteLink"] : url])
        {
            ((RequestCache)dict[@"cache"])([self getValue: [dict responseForKey:@"absoluteLink"] ? dict[@"absoluteLink"] : url]);
        }
        else
        {
            if([dict responseForKey:@"host"])
            {
                [(UIViewController*)dict[@"host"] showSVHUD: self.lang ? @"Loading" : @"Đang tải" andOption:0];
            }
        }
        if([dict responseForKey:@"overrideLoading"])
        {
            if([dict responseForKey:@"host"])
            {
                [(UIViewController*)dict[@"host"] showSVHUD: self.lang ? @"Loading" : @"Đang tải" andOption:0];
            }
        }
    }
    else
    {
        if([dict responseForKey:@"absoluteLink"])
        {
            request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:dict[@"absoluteLink"]]];
        }
        else
        {
            request = [self REQUEST];
        }
        
        post = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        for(NSString * key in post.allKeys)
        {
            if([key isEqualToString:@"host"] || [key isEqualToString:@"completion"] || [key isEqualToString:@"method"] || [key isEqualToString:@"checkmark"] || [key isEqualToString:@"cache"])
            {
                [post removeObjectForKey:key];
            }
        }
        
        [request setPostBody:(NSMutableData*)[[post bv_jsonStringWithPrettyPrint:NO] dataUsingEncoding:NSUTF8StringEncoding]];
        
        if([self getValue: [dict responseForKey:@"absoluteLink"] ? dict[@"absoluteLink"] : [post bv_jsonStringWithPrettyPrint:NO]])
        {
            ((RequestCache)dict[@"cache"])([self getValue:[dict responseForKey:@"absoluteLink"] ? dict[@"absoluteLink"] : [post bv_jsonStringWithPrettyPrint:NO]]);
        }
        else
        {
            if([dict responseForKey:@"host"])
            {
                [dict[@"host"] showSVHUD: self.lang ? @"Loading" : @"Đang tải" andOption:0];
            }
        }
        if([dict responseForKey:@"overrideLoading"])
        {
            if([dict responseForKey:@"host"])
            {
                [dict[@"host"] showSVHUD: self.lang ? @"Loading" : @"Đang tải" andOption:0];
            }
        }
    }
    
    __block ASIFormDataRequest *_request = request;
    
    [_request setFailedBlock:^{
        
        if(![self isConnectionAvailable])
        {
            if([dict responseForKey:@"host"])
            {
                [self alert: self.lang ? @"Attention" : @"Thông báo" message: self.lang ? @"Please check your Internet connection" : @"Vui lòng kiểm tra lại kết nối Internet"];
                [dict[@"host"] hideSVHUD];
            }
            
            ((RequestCompletion)dict[@"completion"])(nil, request.error, NO);
        }
        else
        {
            NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:[request.responseString objectFromJSONString]];
            
            if([dict responseForKey:@"checkmark"])
            {
                [result addEntriesFromDictionary:@{@"checkmark":dict[@"checkmark"]}];
            }
            
            ((RequestCompletion)dict[@"completion"])(nil, request.error, [self didRespond:result andHost:dict[@"host"]]);
        }
        
    }];
    
    [_request setCompletionBlock:^{
        
        NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:[request.responseString objectFromJSONString]];
        
        if([dict responseForKey:@"method"])
        {
            [self addValue:request.responseString andKey:[dict responseForKey:@"absoluteLink"] ? dict[@"absoluteLink"] : url];
        }
        else
        {
//            if([result responseForKindOfClass:@"ERR_CODE" andTarget:@"0"] && [[request.responseString objectFromJSONString] responseForKey:@"RESULT"])
            {
                [self addValue:request.responseString andKey:[dict responseForKey:@"absoluteLink"] ? dict[@"absoluteLink"] : [post bv_jsonStringWithPrettyPrint:NO]];
            }
        }
        if([dict responseForKey:@"checkmark"])
        {
            [result addEntriesFromDictionary:@{@"checkmark":dict[@"checkmark"]}];
        }
        
        if([dict responseForKey:@"overrideError"] && dict[@"host"])
        {
            [self hideSVHUD];
        }
        
        ((RequestCompletion)dict[@"completion"])(request.responseString , nil,[dict responseForKey:@"overrideError"] ? YES : [self didRespond:result andHost:dict[@"host"]]);
    }];
    
    [request startAsynchronous];
    
    return request;
}

- (NSString*)returnGetUrl:(NSDictionary*)dict
{
    NSString * getUrl = @"";
    for(NSString * key in dict.allKeys)
    {
        if([key isEqualToString:@"host"] || [key isEqualToString:@"CMD_CODE"] || [key isEqualToString:@"completion"] || [key isEqualToString:@"method"])
        {
            continue;
        }
        getUrl = [NSString stringWithFormat:@"%@%@=%@&",getUrl,key,dict[key]];
    }
    
    return [getUrl substringToIndex:getUrl.length-(getUrl.length>0)];
}

- (void)didAddCheckMark:(NSDictionary*)dict andHost:(UIViewController*)host
{
    [host showSVHUD:[dict[@"status"] boolValue] ? self.lang ? @"Success" :  @"Thành công" : self.lang ? @"Error" : @"Xảy ra lỗi" andOption:[dict[@"status"] boolValue] ? 1 : 2];
}

- (BOOL)isConnectionAvailable
{
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityRef add;
    add = SCNetworkReachabilityCreateWithName(NULL, "www.apple.com" );
    Boolean success = SCNetworkReachabilityGetFlags(add, &flags);
    CFRelease(add);
    
    bool canReach = success
    && !(flags & kSCNetworkReachabilityFlagsConnectionRequired)
    && (flags & kSCNetworkReachabilityFlagsReachable);
    
    return canReach;
}

@end
