//
//  NSDictionary+XBExtension.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 5/19/15.
//
//

#import <Foundation/Foundation.h>

#define XBDictionary(X) [NSDictionary dictionaryWithContentsOfPlist:X]

@interface NSDictionary (XBExtension)

+ (NSMutableDictionary *)dictionaryWithContentsOfPlist:(NSString *)plistname;
+ (NSMutableDictionary *)dictionaryWithContentsOfPlist:(NSString *)plistname bundleName:(NSString *)name;

@end
