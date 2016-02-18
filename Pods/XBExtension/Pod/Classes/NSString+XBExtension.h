//
//  NSString+XBExtension.h
//  Pods
//
//  Created by Binh Nguyen Xuan on 6/3/15.
//
//

#import <Foundation/Foundation.h>

@interface NSString (XBExtension)

+ (NSString *)uuidString;

- (NSDate *)dateWithFormat:(NSString *)format;
- (NSString *)convertFromDateFormat:(NSString *)fromFormat toDateFormat:(NSString *)toFormat;
- (NSString *)stringValue;

- (BOOL)isNumeric;

@end
