//
//  EM_MenuView.h
//  Emoticon
//
//  Created by thanhhaitran on 2/7/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "CustomIOS7AlertView.h"

typedef void (^Completion)(int index);

@interface EM_MenuView : CustomIOS7AlertView

- (id)initWithMenu:(NSDictionary*)info;

- (id)initWithMenu;

- (void)showWithCompletion:(Completion)completion;

@property(nonatomic,copy) Completion completion;

@end
