//
//  UIImage+XBExtension.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 10/30/15.
//
//

#import "UIImage+XBExtension.h"
#import "FontAwesomeKit.h"

@implementation UIImage (XBExtension)

+ (instancetype)faIconNamed:(NSString *)name color:(UIColor *)color size:(CGSize)size
{
    NSDictionary *allIcon = [FAKFontAwesome allIcons];
    NSString *code = [[allIcon allKeysForObject:name] lastObject];
    if (code)
    {
        FAKFontAwesome *icon = [FAKFontAwesome iconWithCode:code size:size.height];
        [icon addAttribute:NSForegroundColorAttributeName value:color];
        return [icon imageWithSize:CGSizeMake(size.width, size.height)];
    }
    return nil;
}

@end
