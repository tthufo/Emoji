//
//  DropAlert.h
//  Pods
//
//  Created by thanhhaitran on 2/27/16.
//
//

#import <Foundation/Foundation.h>

typedef void (^DropAlertCompletion)(int indexButton, id object);

@interface DropAlert : NSObject

+ (DropAlert*)shareInstance;

- (void)alertWithInfor:(NSDictionary*)dict andCompletion:(DropAlertCompletion)completion;

@end
