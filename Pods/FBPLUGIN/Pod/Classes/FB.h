//
//  FB.h
//  Pods
//
//  Created by thanhhaitran on 12/15/15.
//
//

#import <Foundation/Foundation.h>

typedef void (^FBCompletion)(NSString * responseString, id object, int errorCode, NSString *description, NSError * error);

@interface FB : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (FB*)shareInstance;

- (void)applicationDidBecomeActive:(UIApplication *)application;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)signoutFacebook;
- (void)startLoginFacebookWithCompletion:(FBCompletion)completion;

- (void)startShareWithInfo:(NSArray*)items andBase:(UIView*)baseView andRoot:(UIViewController*)base andCompletion:(FBCompletion)completion;
- (void)startPickImageWithOption:(BOOL)isCamera andBase:(UIView*)baseView andRoot:(UIViewController*)base andCompletion:(FBCompletion)completion;

- (void)didShareFacebook:(NSDictionary*)dict andCompletion:(FBCompletion)completion;

@property (nonatomic, retain) NSString * facebookAppID;


@end
