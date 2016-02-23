//
//  FB.m
//  Pods
//
//  Created by thanhhaitran on 12/15/15.
//
//

#import "FB.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "NSObject+Category.h"

static FB * instance = nil;

@interface FB ()<FBSDKSharingDelegate>
{
    
}
@end

@implementation FB 
{
    FBCompletion completionBlock;
    
    UIPopoverController * popover;
}

+ (FB*)shareInstance
{
    if(!instance)
    {
        instance = [FB new];
    }
    return instance;
}

- (void)startPickImageWithOption:(BOOL)isCamera andBase:(UIView*)baseView andRoot:(UIViewController*)base andCompletion:(FBCompletion)completion
{
    completionBlock = completion;

    UIImagePickerController * ipc = [[UIImagePickerController alloc] init];
    
    ipc.delegate = self;
    
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && isCamera)
    {
        [self alert:@"Error" message:@"Camera not present"];
        
        return;
    }
    
    ipc.sourceType = !isCamera ? UIImagePickerControllerSourceTypeSavedPhotosAlbum : UIImagePickerControllerSourceTypeCamera;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [base presentViewController:ipc animated:YES completion:nil];
    }
    else
    {
        CGRect rect ;
        
        if(!baseView)
        {
            rect = CGRectMake(base.view.frame.size.width/2, base.view.frame.size.height/2, 0, 0);
        }
        else
        {
            rect = baseView.frame;
        }
        
        if(!popover)
            popover = [[UIPopoverController alloc] initWithContentViewController:ipc];
        
        [popover presentPopoverFromRect:rect inView:base.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [popover dismissPopoverAnimated:YES];
    }
    
    completionBlock(nil, [info objectForKey:UIImagePickerControllerOriginalImage], 1, @"done", nil);
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    completionBlock(nil, nil, -1, @"cancel", nil);
}

- (void)startShareWithInfo:(NSArray*)items andBase:(UIView*)baseView andRoot:(UIViewController*)base andCompletion:(FBCompletion)completion
{
    completionBlock = completion;
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [base presentViewController:activityController animated:YES completion:nil];
    }
    else
    {
        CGRect rect ;
        
        if(!baseView)
        {
            rect = CGRectMake(base.view.frame.size.width/2, base.view.frame.size.height/2, 0, 0);
        }
        else
        {
            rect = baseView.frame;
        }
        
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityController];
        
        [popup presentPopoverFromRect:rect inView:base.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
        
        completionBlock(nil, nil, completed ? 1 : -1, @"done", nil);
        
    }];
}

- (void)startLoginFacebookWithCompletion:(FBCompletion)completion
{
    [FBSDKSettings setAppID:self.facebookAppID];
    completionBlock = completion;
    if ([FBSDKAccessToken currentAccessToken])
    {
        [self requestFacebookInformation];
    }
    else
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
            if (error)
            {
                completionBlock(nil, nil, -1, error.localizedDescription, error);
            }
            else if (result.isCancelled)
            {
                completionBlock(nil, nil, -1, error.localizedDescription, nil);
            }
            else
            {
                [self requestFacebookInformation];
            }
        }];
    }
}

- (void)requestFacebookInformation
{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    [self showSVHUD:[dictionary responseForKey:@"lang"] ? @"Loading" : @"Đang tải" andOption:0];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email"}]
     
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (error)
         {
             [self hideSVHUD];
             completionBlock(nil, nil, -1, error.localizedDescription, error);
             return;
         }
         [self didRequestAvatarWithInfo:result];
     }];
}

- (void)didRequestAvatarWithInfo:(NSDictionary *)dict
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"me/?fields=picture,id,name"]
                                  parameters:nil
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error)
     {
         if (!error)
         {
             NSMutableDictionary * data = [dict reFormat];
             
             data[@"avatar"] = result[@"picture"][@"data"][@"url"];
             
             completionBlock(@"ok",@{@"info":data} , 0, nil, error);
         }
         else
         {
             completionBlock(nil, nil, -1, @"errormessage", error);
         }
         [self hideSVHUD];
     }];
}

- (void)signoutFacebook
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logOut];
    }
    instance = nil;
}

- (void)didShareFacebook:(NSDictionary*)dict andCompletion:(FBCompletion)completion
{
    completionBlock = completion;
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:dict[@"content"]];    
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.delegate = self;
    dialog.fromViewController = dict[@"host"];
    dialog.shareContent = content;
    dialog.mode = FBSDKShareDialogModeAutomatic;
    [dialog show];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    completionBlock(nil, error, -1, error.localizedDescription, error);
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    completionBlock(nil, results, 1, nil, nil);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    completionBlock(nil, nil, -1, nil, nil);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if(!dictionary)
    {
        NSLog(@"Check your Info.plist is not right path or name");
    }
    
    if (!dictionary[@"FacebookAppID"])
    {
        NSLog(@"Please setup FacebookAppID in Plist");
    }
    else
    {
        self.facebookAppID = dictionary[@"FacebookAppID"];
    }
    if (!dictionary[@"FacebookDisplayName"])
    {
        NSLog(@"Please setup FacebookDisplayName in Plist");
    }
    if (dictionary[@"FacebookAppID"])
    {
        BOOL found = NO;
        NSString *appID = [NSString stringWithFormat:@"fb%@", dictionary[@"FacebookAppID"]];
        if (dictionary[@"CFBundleURLTypes"])
        {
            for (NSDictionary *item in dictionary[@"CFBundleURLTypes"])
            {
                if (item[@"CFBundleURLSchemes"])
                {
                    for (NSString *scheme in item[@"CFBundleURLSchemes"])
                    {
                        if ([scheme isEqualToString:appID])
                        {
                            found = YES;
                            break;
                        }
                    }
                }
            }
        }
        if (!found)
        {
            NSLog(@"Please setup URL types in Plist as %@", appID);
        }
        
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


@end
