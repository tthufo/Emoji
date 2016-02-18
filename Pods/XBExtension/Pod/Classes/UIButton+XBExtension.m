//
//  UIButton+XBExtension.m
//  Pods
//
//  Created by Binh Nguyen Xuan on 9/5/15.
//
//

#import "UIButton+XBExtension.h"
#import "FontAwesomeKit.h"

@implementation UIButton (XBExtension)
@dynamic imageName;
@dynamic title;
@dynamic faIconName;
@dynamic faBackgroundIconName;

- (void)setFaBackgroundIconName:(NSString *)faBackgroundIconName
{
    NSDictionary *allIcon = [FAKFontAwesome allIcons];
    NSString *code = [[allIcon allKeysForObject:faBackgroundIconName] lastObject];
    if (code)
    {
        FAKFontAwesome *icon = [FAKFontAwesome iconWithCode:code size:24];
        [icon addAttribute:NSForegroundColorAttributeName value:self.tintColor];
        [self setBackgroundImage:[icon imageWithSize:self.frame.size] forState:UIControlStateNormal];
    }
}

- (NSString *)faBackgroundIconName
{
    return nil;
}

- (void)setFaIconName:(NSString *)faIconName
{
    NSDictionary *allIcon = [FAKFontAwesome allIcons];
    NSString *code = [[allIcon allKeysForObject:faIconName] lastObject];
    if (code)
    {
        FAKFontAwesome *icon = [FAKFontAwesome iconWithCode:code size:24];
        [icon addAttribute:NSForegroundColorAttributeName value:self.tintColor];
        [self setImage:[icon imageWithSize:self.frame.size] forState:UIControlStateNormal];
    }
}

- (NSString *)faIconName
{
    return nil;
}

- (void)setImageName:(NSString *)imageName
{
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (NSString *)imageName
{
    return nil;
}

- (void)setBackgroundImageName:(NSString *)backgroundImageName
{
    [self setBackgroundImage:[UIImage imageNamed:backgroundImageName] forState:UIControlStateNormal];
}

- (NSString *)backgroundImageName
{
    return nil;
}

- (void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
}

- (NSString *)title
{
    [self titleForState:UIControlStateNormal];
}

@end
