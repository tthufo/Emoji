//
//  DropButton.m
//  Pods
//
//  Created by thanhhaitran on 1/13/16.
//
//

#import "DropButton.h"

#import "NSObject+Category.h"

#import "UIImageView+WebCache.h"

#import "AVHexColor.h"

#define screenHeight [UIScreen mainScreen].bounds.size.height

#define screenWidth [UIScreen mainScreen].bounds.size.width

static DropButton * shareButton = nil;

@interface DropButton () <NIDropDownDelegate>
{
    NIDropDown * dropDown;
    
    DropButtonCompletion completionBlock;
    
    NSDictionary * template;
}

@end

@implementation DropButton

@synthesize pList;

+ (DropButton*)shareInstance
{
    if(!shareButton)
    {
        shareButton = [DropButton new];
    }
    
    return shareButton;
}

- (void)didDropDownWithData:(NSArray*)dataList andInfo:(NSDictionary*)dict andCompletion:(DropButtonCompletion)completion
{
    completionBlock = completion;
    
    if(dropDown == nil)
    {
        template = nil;
        
        template = [[NSDictionary new] dictionaryWithPlist:self.pList];
        
        if(!template)
        {
            return;
        }
        
        CGFloat f = [template[@"height"] floatValue];
        
        CGRect windowRect = [dict[@"rect"] CGRectValue];
        
        dropDown = [NIDropDown new];
        
        dropDown._template = template;
        
        dropDown.delegate = self;
        
        [dropDown showDropDownWithRect:windowRect andHeight:&f andData:dataList andDirection:template[@"direction"]];
    }
    else
    {
        [dropDown hideDropDown];
        
        dropDown = nil;
    }
}

- (void)didDropDownWithData:(NSArray*)dataList andCompletion:(DropButtonCompletion)completion
{
    completionBlock = completion;
    
    if(dropDown == nil)
    {
        template = nil;
        
        template = [[NSDictionary new] dictionaryWithPlist:self.pList];
        
        if(!template)
        {
            return;
        }
        
        CGFloat f = [template[@"height"] floatValue];
        
        CGRect windowRect = [self convertRect:self.bounds toView:nil];
        
        dropDown = [NIDropDown new];
        
        dropDown._template = template;
        
        dropDown.delegate = self;
        
        [dropDown showDropDownWithRect:windowRect andHeight:&f andData:dataList andDirection:template[@"direction"]];
    }
    else
    {
        [dropDown hideDropDown];
        
        dropDown = nil;
    }
}

- (void)niDropDownDelegateMethod:(NIDropDown *)sender
{
    if(sender)
    {
        completionBlock(sender.selectedDetails);
    }
    dropDown = nil;
}

@end




@interface NIDropDown ()
{    
    NSString * direction;
    
    CGRect rect;
    
    UIButton * cover;
}

@property(nonatomic, retain) NSArray * datalist;

@end

@implementation NIDropDown

@synthesize tableView;

@synthesize datalist;

@synthesize delegate;

@synthesize cellHeight;

@synthesize selectedDetails;

@synthesize _template;

- (id)showDropDownWithRect:(CGRect)_rect andHeight:(CGFloat *)height andData:(NSArray *)data andDirection:(NSString *)_direction
{
    rect = _rect;
    
    if(![_template responseForKey:@"cellheight"])
    {
        cellHeight = 40;
    }
    else
    {
        cellHeight = [_template[@"cellheight"] floatValue];
    }

    direction = _direction;
    
    
    if(![_direction isEqualToString:@"up"] || ![_direction isEqualToString:@"down"])
    {
        direction = @"down";
    }
    
    tableView = (UITableView *)[super init];
    
    if (self)
    {
        CGRect btn = rect;
        
        self.datalist = [NSArray arrayWithArray:data];
        
        self.layer.masksToBounds = NO;

        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.delegate = self;
        tableView.dataSource = self;
        
        if([_template responseForKey:@"background"] && ((NSString*)_template[@"background"]).length != 0)
        {
            tableView.backgroundColor = [AVHexColor colorWithHexString:_template[@"background"]];
        }
        
        float heightTemp = data.count < 5 ? data.count * cellHeight : *height;
        
        direction = (heightTemp + _rect.origin.y) > screenHeight ? @"up" : @"down";
        
        if ([direction isEqualToString:@"up"])
        {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }
        else if ([direction isEqualToString:@"down"])
        {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            
            if ([direction isEqualToString:@"up"])
            {
                self.frame = CGRectMake(btn.origin.x, btn.origin.y- heightTemp, btn.size.width, heightTemp);
            }
            else if([direction isEqualToString:@"down"])
            {
                self.frame = CGRectMake(btn.origin.x, btn.origin.y + btn.size.height, btn.size.width, heightTemp);
            }
            tableView.frame = CGRectMake(0, 0, btn.size.width, heightTemp);
            
        } completion:^(BOOL finish){}];
        
        [self addSubview:tableView];

        cover = [UIButton buttonWithType:UIButtonTypeCustom];
        
        cover.backgroundColor = [UIColor blackColor];
        
        cover.alpha = 0.1;
        
        cover.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        
        [cover addTarget:self action:@selector(didPressCoverButton) forControlEvents:UIControlEventTouchUpInside];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:cover];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
        
    }
    return self;
}

- (void)didPressCoverButton
{
    [self hideDropDown];
    
    [cover removeFromSuperview];
    
    [self.delegate niDropDownDelegateMethod:nil];
}

- (void)hideDropDown
{
    CGRect btn = rect;
    
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.5];
    
    if ([direction isEqualToString:@"up"])
    {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
    }
    else if ([direction isEqualToString:@"down"])
    {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
    }
    tableView.frame = CGRectMake(0, 0, btn.size.width, 0);
    
    [UIView commitAnimations];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datalist count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:_template[@"identifier"]];
    
    if (cell == nil)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:_template[@"nib"] owner:self options:nil][0];
    }
    
    if([_template responseForKey:@"items"])
    {
        for(NSString * tag in ((NSDictionary*)_template[@"items"]).allKeys)
        {
            ((UILabel*)[self withView:cell tag:[tag intValue]]).text = self.datalist[indexPath.row][_template[@"items"][tag]];
        }
    }
    
    if([_template responseForKey:@"images"])
    {
        for(NSString * tag in ((NSDictionary*)_template[@"images"]).allKeys)
        {
            if([self.datalist[indexPath.row][_template[@"images"][tag]] myContainsString:@"http"])
            {
                [((UIImageView*)[self withView:cell tag:[tag intValue]]) sd_setImageWithURL:[NSURL URLWithString:self.datalist[indexPath.row][_template[@"images"][tag]]] placeholderImage:nil];
            }
            else
            {
                ((UIImageView*)[self withView:cell tag:[tag intValue]]).image = [UIImage imageNamed:self.datalist[indexPath.row][_template[@"images"][tag]]];
            }
        }
    }
    
    if([_template responseForKey:@"cellbackground"] && ((NSArray*)_template[@"cellbackground"]).count > 1)
    {
        cell.backgroundColor = [AVHexColor colorWithHexString:((NSString*)_template[@"cellbackground"][indexPath.row % 2 == 0 ? 0 : 1]).length == 0 ? @"#FFFFFF" : _template[@"cellbackground"][indexPath.row % 2 == 0 ? 0 : 1]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideDropDown];
    selectedDetails = @{@"data":self.datalist[indexPath.row],@"index":@(indexPath.row)};
    [self myDelegate];
}

- (void)myDelegate
{
    [self.delegate niDropDownDelegateMethod:self];
    [cover removeFromSuperview];
}


@end


@implementation DropButton (pList)

- (void)setPListName:(NSString *)pListName
{
    self.pList = pListName;
}

- (NSString*)pListName
{
    return self.pList;
}

@end

