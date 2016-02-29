//
//  DropButton.h
//  Pods
//
//  Created by thanhhaitran on 1/13/16.
//
//

#import <UIKit/UIKit.h>

typedef void (^DropButtonCompletion)(id object);

@class DropButton;

@interface DropButton : UIButton 

+ (DropButton*)shareInstance;

- (void)didDropDownWithData:(NSArray*)dataList andCompletion:(DropButtonCompletion)completion;

- (void)didDropDownWithData:(NSArray*)dataList andInfo:(NSDictionary*)dict andCompletion:(DropButtonCompletion)completion;

@property (nonatomic, retain) NSString * pList;

@end



@class NIDropDown;

@protocol NIDropDownDelegate

- (void) niDropDownDelegateMethod: (NIDropDown *) sender;

@end

@interface NIDropDown : UIView <UITableViewDelegate, UITableViewDataSource>
{

}

@property (nonatomic, retain) NSDictionary * selectedDetails;

@property (nonatomic, retain) id <NIDropDownDelegate> delegate;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, readwrite) int cellHeight;

@property (nonatomic, retain) NSDictionary * _template;

- (void)hideDropDown;

- (id)showDropDownWithRect:(CGRect)_rect andHeight:(CGFloat *)height andData:(NSArray *)data andDirection:(NSString *)_direction;

@end

@interface DropButton (pList)

@property(nonatomic, assign) NSString* pListName;

@end

