//
//  NSDictionary+XBExtension.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 5/19/15.
//
//

#import "XBExtension.h"

@implementation NSDictionary (XBExtension)

+ (NSMutableDictionary *)dictionaryWithContentsOfPlist:(NSString *)plistname
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistname ofType:@"plist"];
    return [[NSDictionary dictionaryWithContentsOfFile:path] deepMutableCopy];
}

+ (NSMutableDictionary *)dictionaryWithContentsOfPlist:(NSString *)plistname bundleName:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"bundle"]];
    NSString *path = [bundle pathForResource:plistname ofType:@"plist"];
    return [[NSDictionary dictionaryWithContentsOfFile:path] deepMutableCopy];
}

@end
