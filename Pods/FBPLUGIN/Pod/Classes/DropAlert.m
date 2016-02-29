//
//  DropAlert.m
//  Pods
//
//  Created by thanhhaitran on 2/27/16.
//
//

#import "DropAlert.h"

#import "JSONKit.h"

#import "NSObject+Category.h"

static DropAlert * __shareInstance = nil;

@interface DropAlert () <UIAlertViewDelegate>
{
    DropAlertCompletion completionBlock;
}

@end

@implementation DropAlert

+ (DropAlert*)shareInstance
{
    if(!__shareInstance)
    {
        __shareInstance = [DropAlert new];
    }
    
    return __shareInstance;
}

- (void)alertWithInfor:(NSDictionary*)dict andCompletion:(DropAlertCompletion)completion
{
    completionBlock = completion;
    
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:dict[@"title"] message:dict[@"message"] delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    alertView.accessibilityLabel = [dict bv_jsonStringWithPrettyPrint:NO];
    
    for( NSString *title in dict[@"buttons"])
    {
        [alertView addButtonWithTitle:title];
    }
    
    [alertView addButtonWithTitle:dict[@"cancel"]];
    
    if([dict responseForKey:@"option"])
    {
        alertView.alertViewStyle = ![dict[@"option"] boolValue] ? UIAlertViewStylePlainTextInput : UIAlertViewStyleLoginAndPasswordInput;
        
        if(alertView.alertViewStyle == UIAlertViewStylePlainTextInput)
        {
            ((UITextField*)[alertView textFieldAtIndex:0]).text = dict[@"text"];
        }
    }
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary * info = [alertView.accessibilityLabel objectFromJSONString];
    
    if([info responseForKey:@"option"])
    {
        if([info[@"option"] boolValue])
        {
            completionBlock(buttonIndex, @{@"uName":[alertView textFieldAtIndex:0].text,@"pWord":[alertView textFieldAtIndex:1].text});
        }
        else
        {
            completionBlock(buttonIndex, @{@"uName":[alertView textFieldAtIndex:0].text});
        }
    }
    
    completionBlock(buttonIndex, nil);
}

@end
