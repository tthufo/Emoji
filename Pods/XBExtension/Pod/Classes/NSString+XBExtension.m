//
//  NSString+XBExtension.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 6/3/15.
//
//

#import "NSString+XBExtension.h"
#import "NSDate+XBExtension.h"

@implementation NSString (XBExtension)

+ (NSString *)uuidString
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

- (NSDate *)dateWithFormat:(NSString *)format
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    return [df dateFromString:self];
}

- (NSString *)convertFromDateFormat:(NSString *)fromFormat toDateFormat:(NSString *)toFormat
{
    NSDate *date = [self dateWithFormat:fromFormat];
    return [date stringWithFormat:toFormat];
}

- (NSString *)stringValue
{
    return self;
}

- (BOOL)isNumeric
{
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:self];
    return [alphaNums isSupersetOfSet:inStringSet];
}

@end
