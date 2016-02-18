//
//  EM_MenuView.m
//  Emoticon
//
//  Created by thanhhaitran on 2/7/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_MenuView.h"

@interface EM_MenuView ()

@end

@implementation EM_MenuView

@synthesize completion;

- (id)initWithMenu:(NSDictionary*)info
{
    self = [self init];
    [self setContainerView:[self didCreateView:info]];
    [self setUseMotionEffects:true];
    return self;
}

- (id)initWithMenu
{
    self = [self init];
    [self setContainerView:[self didCreateView]];
    [self setUseMotionEffects:true];
    return self;
}

- (UIView*)didCreateView
{
    UIScrollView *commentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 20, 378)];
    
    commentView.contentSize = CGSizeMake(screenWidth - 20, 875);
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][2];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, 875);
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (UIView*)didCreateView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 20, 378)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][2];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    ((UIImageView*)[self withView:contentView tag:11]).image = dict[@"image"];
    
    
    [(UIButton*)[self withView:contentView tag:12] addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [(UIButton*)[self withView:contentView tag:14] addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];

    [((UIButton *)[contentView viewWithTag:15]) addTapTarget:self action:@selector(didPressButton:)];
    
    [(UIButton*)[self withView:contentView tag:16] addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (void)didPressButton:(UIButton*)button
{
    completion(button.tag);
}

- (void)showWithCompletion:(Completion)_completion
{
    completion = _completion;
    
    [self show];
}

- (void)close
{
    [super close];
}

@end
