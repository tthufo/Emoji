//
//  NSObject+XBExtension.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 5/19/15.
//
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface NSObject (XBExtension)

- (id)objectForPath:(NSString *)string;

- (void)alert:(NSString *)title message:(NSString *)message;

- (void)alert:(NSString *)title message:(NSString *)message close:(NSString *)close;

- (MBProgressHUD *)showHUD:(NSString *)string;

- (void)hideHUD;

- (id)deepMutableCopy;

@end
