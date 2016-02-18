//
//  NSArray+XBExtension.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 5/19/15.
//
//

#import <Foundation/Foundation.h>

#define XBArray(X) [NSArray arrayWithContentsOfPlist:X]

@interface NSArray (XBExtension)

+ (NSMutableArray *)arrayWithContentsOfPlist:(NSString *)plistname;
+ (NSMutableArray *)arrayWithContentsOfPlist:(NSString *)plistname bundleName:(NSString *)name;
- (NSArray *)arrayOrderedByString:(NSString *)orderField accending:(BOOL)accending;
- (NSArray *)arrayOrderedByNumber:(NSString *)orderField accending:(BOOL)accending;

@end
