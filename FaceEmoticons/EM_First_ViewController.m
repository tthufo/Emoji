//
//  EM_First_ViewController.m
//  Emoticon
//
//  Created by thanhhaitran on 2/5/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_First_ViewController.h"

#import "TFHpple.h"

#import "M13ContextMenu.h"

#import "M13ContextMenuItemIOS7.h"

#import "DropButton.h"

#define ratio 0.5

#define sideRatio 0.2

@interface EM_First_ViewController ()<UITableViewDataSource, UITableViewDelegate, M13ContextMenuDelegate>

{
    NSMutableArray * dataList, * menuList, * sideMenuList, * optionList, * multiSelection;
    
    int count;
    
    IBOutlet UICollectionView * collectionView;
    
    NSString * url, * tempIndexPath;
    
    UIView * menu, * sideMenu;
    
    IBOutlet UIButton * cover;
    
    UIImage * tempImage;
    
    UIImageView * preview;
    
    BOOL isShort;
    
    CGRect start;
    
    M13ContextMenu * contextMenu;
    
    UILongPressGestureRecognizer * longPress;
    
    IBOutlet UITextView * emoText;
    
    IBOutlet UIView * previewEmo;
}

@end

@implementation EM_First_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    count = 1;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[AVHexColor colorWithHexString:@"#FFFFFF"]}];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7)
    {
        self.navigationController.navigationBar.barTintColor = [AVHexColor colorWithHexString:@"#136BFA"];
        self.navigationController.navigationBar.translucent = NO;
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [AVHexColor colorWithHexString:@"#136BFA"];
    }
    
    UIBarButtonItem * menuB = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressMenu)];
    self.navigationItem.leftBarButtonItem = menuB;
    
    UIBarButtonItem * share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(didPressShare)];
    self.navigationItem.rightBarButtonItem = share;
    
    [collectionView registerNib:[UINib nibWithNibName:@"EM_Cells" bundle:nil] forCellWithReuseIdentifier:@"imageCell"];
    
    dataList = [NSMutableArray new];
    
    multiSelection = [NSMutableArray new];
    
    sideMenuList = [[NSMutableArray alloc] initWithArray:@[@"Save",@"Copy",@"Share",@"Close"]];
    
    menu = [self returnView];
    
    sideMenu = [self returnSideMenu];
    
    cover.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    
    preview = [self returnImage:CGRectMake(15, (screenHeight - (screenWidth - (screenWidth * sideRatio)) - 30) / 2 - 15 , (screenWidth - (screenWidth * sideRatio)) - 30 , (screenWidth - (screenWidth * sideRatio)) - 30)];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":@"https://dl.dropboxusercontent.com/s/dnssdwwg9m84ndr/Emoji1_1.plist",@"overrideError":@(1),@"overrideLoading":@(1),@"host":self} withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSError *error, BOOL isValidated) {
        
        if(!isValidated)
        {
            return ;
        }
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError * er = nil;
        NSDictionary *dict = [self returnDictionary:[XMLReader dictionaryForXMLData:data
                                                                            options:XMLReaderOptionsProcessNamespaces
                                                                              error:&er]];
        
        [System addValue:@{@"banner":dict[@"banner"],@"fullBanner":dict[@"fullBanner"],@"adsMob":dict[@"ads"]} andKey:@"adsInfo"];
        
        BOOL isUpdate = [dict[@"version"] compare:[self appInfor][@"majorVersion"] options:NSNumericSearch] == NSOrderedDescending;
        
        if(isUpdate)
        {
            [[DropAlert shareInstance] alertWithInfor:@{/*@"option":@(0),@"text":@"wwww",*/@"cancel":@"Close",@"buttons":@[@"Download now"],@"title":@"New Update",@"message":dict[@"update_message"]} andCompletion:^(int indexButton, id object) {
                switch (indexButton)
                {
                    case 0:
                    {
                        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:dict[@"url"]]])
                        {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dict[@"url"]]];
                        }
                    }
                        break;
                    case 1:
                        
                        break;
                    default:
                        break;
                }
            }];
        }
        
        [self didShowAdsBanner];
        
        [self didPrepareData:YES];
        
        [self didRequestData];
        
    }];

    M13ContextMenuItemIOS7 *bookmarkItem = [[M13ContextMenuItemIOS7 alloc] initWithUnselectedIcon:[UIImage imageNamed:@"Fbook"] selectedIcon:[UIImage imageNamed:@"Fbook"]];
    M13ContextMenuItemIOS7 *uploadItem = [[M13ContextMenuItemIOS7 alloc] initWithUnselectedIcon:[UIImage imageNamed:@"Safari"] selectedIcon:[UIImage imageNamed:@"Safari"]];
    M13ContextMenuItemIOS7 *trashIcon = [[M13ContextMenuItemIOS7 alloc] initWithUnselectedIcon:[UIImage imageNamed:@"VOC_icon"] selectedIcon:[UIImage imageNamed:@"VOC_icon"]];
    M13ContextMenuItemIOS7 *fmess = [[M13ContextMenuItemIOS7 alloc] initWithUnselectedIcon:[UIImage imageNamed:@"Fmess"] selectedIcon:[UIImage imageNamed:@"Fmess"]];
    M13ContextMenuItemIOS7 *twitter = [[M13ContextMenuItemIOS7 alloc] initWithUnselectedIcon:[UIImage imageNamed:@"twitte"] selectedIcon:[UIImage imageNamed:@"twitte"]];

    contextMenu = [[M13ContextMenu alloc] initWithMenuItems:@[bookmarkItem, uploadItem, trashIcon, fmess, twitter]];
    
    contextMenu.delegate = self;
    
    UILongPressGestureRecognizer * press = [[UILongPressGestureRecognizer alloc] initWithTarget:contextMenu action:@selector(showMenuUponActivationOfGetsure:)];
    [(UIButton*)[self withView:previewEmo tag:12] addGestureRecognizer:press];
}

- (void)didShowAdsBanner
{
    if([[self infoPlist][@"showAds"] boolValue])
    {
        if([[System getValue:@"adsInfo"][@"adsMob"] boolValue] && [System getValue:@"adsInfo"][@"banner"])
        {
            [[Ads sharedInstance] G_didShowBannerAdsWithInfor:@{@"host":self,@"X":@(320),@"Y":@(screenHeight - 64 - 50),@"adsId":[System getValue:@"adsInfo"][@"banner"],@"device":@""} andCompletion:^(BannerEvent event, NSError *error, id banner) {
                
                switch (event)
                {
                    case AdsDone:
                        
                        break;
                    case AdsFailed:
                        
                        break;
                    default:
                        break;
                }
            }];
        }
    }
    if([[self infoPlist][@"showAds"] boolValue])
    {
        if(![[System getValue:@"adsInfo"][@"adsMob"] boolValue])
        {
            [[Ads sharedInstance] S_didShowBannerAdsWithInfor:@{@"host":self,@"Y":@(screenHeight - 64 - 50)} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
                switch (event)
                {
                    case AdsDone:
                    {
                        
                    }
                        break;
                    case AdsFailed:
                    {
                        
                    }
                        break;
                    case AdsWillPresent:
                    {
                        
                    }
                        break;
                    case AdsWillLeave:
                    {
                        
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
    }
}

- (NSDictionary*)returnDictionary:(NSDictionary*)dict
{
    NSMutableDictionary * result = [NSMutableDictionary new];
    
    for(NSDictionary * key in dict[@"plist"][@"dict"][@"key"])
    {
        result[key[@"jacknode"]] = dict[@"plist"][@"dict"][@"string"][[dict[@"plist"][@"dict"][@"key"] indexOfObject:key]][@"jacknode"];
    }
    
    return result;
}

- (void)didBeginShowMenu
{
    if(![self getValue:@"detail"])
    {
        [self addValue:@"1" andKey:@"detail"];
    }
    else
    {
        int k = [[self getValue:@"detail"] intValue] + 1 ;
        
        [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"detail"];
    }
    
    if([[self getValue:@"detail"] intValue] % 4 == 0)
    {
        [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
    }
}

- (BOOL)shouldShowContextMenu:(M13ContextMenu *)contextMenu atPoint:(CGPoint)point
{
    return YES;
}

- (void)contextMenu:(M13ContextMenu *)contextMenu atPoint:(CGPoint)point didSelectItemAtIndex:(NSInteger)index
{
    NSIndexPath* indexPath = [collectionView indexPathForItemAtPoint:point];
    
    UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
    appPasteBoard.persistent = YES;
    [appPasteBoard setString: ![[System getValue:@"option"] boolValue] ? dataList[indexPath.item][@"image"] : emoText.text];
    
    switch (index)
    {
        case 0:
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://"]];
            }
            else
            {
                [self alert:@"Attention" message:@"Can't open Facebook"];
            }
        }
            break;
        case 3:
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://messaging"]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://messaging"]];
            }
            else
            {
                [self alert:@"Attention" message:@"Can't open Facebook Messenger"];
            }
        }
            break;
        case 2:
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms://"]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"sms://"]];
            }
            else
            {
                [self alert:@"Attention" message:@"Can't open Message"];
            }
        }
            break;
        case 1:
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"https://facebook.com"]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://facebook.com"]];
            }
            else
            {
                [self alert:@"Attention" message:@"Can't open Safari"];
            }
        }
            break;
        case 4:
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://"]];
            }
            else
            {
                [self alert:@"Attention" message:@"Can't open Twitter"];
            }
        }
            break;
        default:
            break;
    }
}

- (void)didPrepareData:(BOOL)isShow
{
    if(![System getValue:@"option"])
    {
        [System addValue:@(0) andKey:@"option"];
    }
    
    self.title = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"title"];

    url = [NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"][0][@"cat"];
    
    menuList = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithContentsOfPlist:isShow ? @"menu" : @"menuShort"]];
    
    optionList = [@[@{@"title": ![[System getValue:@"option"] boolValue] ? @"Multi selection" : @"Single selection"}, @{@"title":@"Tell your friend"}, @{@"title":@"How to"}] mutableCopy];
    
    if(![[System getValue:@"option"] boolValue])
    {
        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:contextMenu action:@selector(showMenuUponActivationOfGetsure:)];
        [collectionView addGestureRecognizer:longPress];
    }
    
    previewEmo.frame = CGRectMake(0, screenHeight - (![[System getValue:@"option"] boolValue] ? 0 : 100 + 64), screenWidth, 100);
    [self.view addSubview:previewEmo];
    
    collectionView.contentInset = UIEdgeInsetsMake(0, 0,[[System getValue:@"option"] boolValue] ? 100 : 50, 0);
}


- (void)didPressMenu
{
    DropButton * sender = [DropButton shareInstance];
    
    sender.pList = @"format";
    
    [sender didDropDownWithData:menuList andInfo:@{@"rect":[NSValue valueWithCGRect:CGRectMake(0, -34, 160, 100)]} andCompletion:^(id object) {
        
        if([object[@"data"][@"title"] isEqualToString:self.title])
        {
            return;
        }
        
        count = 1;
        
        self.title = object[@"data"][@"title"];
        
        url = object[@"data"][@"cat"];
        
        [self didRequestData];
        
    }];
    
    if(![self getValue:@"menu"])
    {
        [self addValue:@"1" andKey:@"menu"];
    }
    else
    {
        int k = [[self getValue:@"menu"] intValue] + 1 ;
        
        [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"menu"];
    }
    
    if([[self getValue:@"menu"] intValue] % 8 == 0)
    {
        [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
    }
}

- (void)didPressShare
{
    DropButton * sender = [DropButton shareInstance];
    
    sender.pList = @"options";
    
    [sender didDropDownWithData:optionList andInfo:@{@"rect":[NSValue valueWithCGRect:CGRectMake(screenWidth - 150, -34, 150, 100)]} andCompletion:^(id object) {
        
        switch ([object[@"index"] intValue]) {
            case 0:
            {
                [System addValue:[[System getValue:@"option"] boolValue] ? @(0) : @(1) andKey:@"option"];
                [optionList removeAllObjects];
                optionList = [@[@{@"title": ![[System getValue:@"option"] boolValue] ? @"Multi selection" : @"Single selection"}, @{@"title":@"Tell your friend"}, @{@"title":@"How to!"}] mutableCopy];
                
                if(![[System getValue:@"option"] boolValue])
                {
                    if(!longPress)
                        longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:contextMenu action:@selector(showMenuUponActivationOfGetsure:)];
                    [collectionView addGestureRecognizer:longPress];
                    [self showToast:@"Single selection" andPos:0];
                }
                else
                {
                    [collectionView removeGestureRecognizer:longPress];
                    [self showToast:@"Mutil selection" andPos:0];
                }
                
                [UIView animateWithDuration:0.3 /*delay:0.5 usingSpringWithDamping:0.9 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut*/ animations:^{
                    
                    CGRect rect = previewEmo.frame;
                    
                    rect.origin.y += previewEmo.frame.origin.y == screenHeight ? -100 - 64 : 100 + 64;
                    
                    previewEmo.frame = rect;
                    
                } completion:^(BOOL finished) {
                    
                    collectionView.contentInset = UIEdgeInsetsMake(0, 0, previewEmo.frame.origin.y == screenHeight ? 50 : 100, 0);
                    
                }];
            }
                break;
            case 1:
            {
                 [[FB shareInstance] startShareWithInfo:@[@"Plenty of emotion stickers for your message and chatting, have fun!",@"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100",[UIImage imageNamed:@"emoji"]] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {
                 
                 }];
            }
                break;
            case 2:
            {
                EM_MenuView * pre = [[EM_MenuView alloc] initWithMenu];
                [pre show];
            }
                break;
            default:
                break;
        }
        
    }];
    
    if(![self getValue:@"share"])
    {
        [self addValue:@"1" andKey:@"share"];
    }
    else
    {
        int k = [[self getValue:@"share"] intValue] + 1 ;
        
        [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"share"];
    }
    
    if([[self getValue:@"share"] intValue] % 8 == 0)
    {
        [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
    }
}

- (IBAction)didPressCover:(id)sender
{
    if([self.view.subviews containsObject:sideMenu])
    {
        [self didPressSideMenu];
    }
    else
    {
        [self didPressMenu];
    }
}

- (UIView*)returnView
{
    UIView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][0];
    
    ((UITableView *)[self withView:mem tag:11]).delegate = self;
    
    ((UITableView *)[self withView:mem tag:11]).dataSource = self;

    return mem;
}

- (UIView*)returnSideMenu
{
    UIView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][3];
    
    ((UITableView *)[self withView:mem tag:12]).delegate = self;
    
    ((UITableView *)[self withView:mem tag:12]).dataSource = self;
    
    return mem;
}

- (UIImageView*)returnImage:(CGRect)frame
{
    UIImageView * mem = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][4];

    mem.frame = frame;

    return mem;
}

- (void)didPressSideMenu
{
    BOOL isMenu = [self.view.subviews containsObject:sideMenu];
    
    if(!isMenu)
    {
        sideMenu.frame = CGRectMake(screenWidth, (screenHeight - 200) / 2 - 44, screenWidth * sideRatio, 200);
        
        [self.view addSubview:sideMenu];
    }

    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = sideMenu.frame;
        
        rect.origin.x += isMenu ? screenWidth * sideRatio : - screenWidth * sideRatio;
        
        sideMenu.frame = rect;
        
        collectionView.userInteractionEnabled = isMenu;
        
    } completion:^(BOOL finished) {
        
        if (finished && isMenu && sideMenu.frame.origin.x != screenWidth * sideRatio)
        {
            [sideMenu removeFromSuperview];
            [cover removeFromSuperview];
            [self didChangeImagePosition:start isBack:NO];
        }
        else
        {
            [self.view insertSubview:cover belowSubview:sideMenu];
        }
        
    }];
}

- (void)didLoadMore
{
    count ++;
    
    [self didRequestData];
}

- (void)didReceiveData:(NSString*)data andIsReset:(BOOL)isReset
{
    if(count == 1)
        [dataList removeAllObjects];
    
    TFHpple *parser = [TFHpple hppleWithHTMLData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *pathQuery = @"//ul[@class='emoji-list']";
    
    NSArray *nodes = [parser searchWithXPathQuery:pathQuery];
    
    for (TFHppleElement *element in nodes)
    {
        for(TFHppleElement *child in element.children)
        {
            for(TFHppleElement * c in child.children)
            {
                for(TFHppleElement * last in c.children)
                {
                    for(TFHppleElement * end in last.children)
                    {
                        if([end content])
                        {
                            [dataList addObject:@{@"image":[end content]}];
                        }
                    }
                }
            }
        }
    }
    
    [collectionView reloadData];
    
    if(isReset)
        [collectionView setContentOffset:CGPointZero animated:NO];
}

- (void)didRequestData
{
    if(count == 1)
    {
        [dataList removeAllObjects];
    }
    [[LTRequest sharedInstance] didInitWithUrl:@{@"absoluteLink":url,@"host":self} withCache:^(NSString *cacheString) {
        
        [self didReceiveData:cacheString andIsReset:YES];
        
    } andCompletion:^(NSString *responseString, NSError *error, BOOL isValidated) {
        
        [self didReceiveData:responseString andIsReset:NO];

    }];
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableView.tag == 11 ? menuList.count : sideMenuList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"menu"];
    
    if(!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][1];
    }
    
    if(_tableView.tag == 11)
    {
        ((UILabel*)[self withView:cell tag:11]).text = menuList[indexPath.row][@"title"];
        
        ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#4BABE4"];

        [((UIView*)[self withView:cell tag:12]) withBorder:@{@"Bcorner":@(0),@"Bwidth": @(1.5) ,@"Bhex":@"#4BABE4"}];
        
        if([menuList[indexPath.row][@"title"] isEqualToString:self.title])
        {
            ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#D6544E"];
            
            ((UILabel*)[self withView:cell tag:11]).alpha = 0.3;
            
            [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
                
                ((UILabel*)[self withView:cell tag:11]).alpha = 1;
                
            } completion:nil];
        }
    }
    else
    {
        ((UILabel*)[self withView:cell tag:11]).text = sideMenuList[indexPath.row];
        
        ((UILabel*)[self withView:cell tag:11]).textAlignment = NSTextAlignmentCenter;
        
        ((UILabel*)[self withView:cell tag:11]).textColor = [AVHexColor colorWithHexString:@"#4BABE4"];
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(_tableView.tag == 11)
    {
        if([menuList[indexPath.row][@"title"] isEqualToString:self.title])
        {
            [self didPressMenu];
            
            return;
        }
        
        count = 1;
        
        self.title = menuList[indexPath.row][@"title"];
        
        [_tableView reloadData];
        
        url = menuList[indexPath.row][@"cat"];
        
        [self didRequestData];
        
        [self didPressMenu];
    }
    else
    {
        switch(indexPath.row)
        {
            case 0:
            {
                UIImageWriteToSavedPhotosAlbum(tempImage,self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void * _Nullable)(dataList[[tempIndexPath intValue]][@"image"]));
            }
                break;
            case 1:
            {
                UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
                appPasteBoard.persistent = YES;
                [appPasteBoard setImage:tempImage];
            }
                break;
            case 2:
            {
                [[FB shareInstance] startShareWithInfo:@[@"Plenty of emotion stickers for your message and chatting, have fun!", @"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100", tempImage] andBase:nil andRoot:self andCompletion:^(NSString *responseString, id object, int errorCode, NSString *description, NSError *error) {

                    }];
            }
                break;
                case 3:
            {
                
            }
                break;
            default:
                break;
        }
        
        if(indexPath.row != 3)
        {
            if(![self getValue:@"detail"])
            {
                [self addValue:@"1" andKey:@"detail"];
            }
            else
            {
                int k = [[self getValue:@"detail"] intValue] + 1 ;

                [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"detail"];
            }

            if([[self getValue:@"detail"] intValue] % 4 == 0)
            {
                [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
            }
        }
        
        [self didPressCover:nil];
    }
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return dataList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    ((UILabel*)[self withView:cell tag:15]).text = dataList[indexPath.item][@"image"];
    
    ((UILabel*)[self withView:cell tag:15]).font = [UIFont fontWithName:@"AppleColorEmoji" size:29.0];
    
    NSArray * data = [System getFormat:@"key=%@" argument:@[dataList[indexPath.item][@"image"]]];
    
    ((UIImageView*)[self withView:cell tag:12]).alpha = data.count == 0 ? 0 : 1.0;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(screenWidth / 5 - 0.0, screenWidth / 5 - 0.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(![[System getValue:@"option"] boolValue]) return;
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self pulse:[_collectionView cellForItemAtIndexPath:indexPath] toSize:1.4 withDuration:0.3];
    
    [multiSelection addObject:dataList[indexPath.item][@"image"]];
    
    NSMutableString * mutable = [NSMutableString new];
    
    for(NSString * string in multiSelection)
    {
        [mutable appendString:string];
    }
    
    emoText.text = mutable;
    
    if(![self getValue:@"multi"])
    {
        [self addValue:@"1" andKey:@"multi"];
    }
    else
    {
        int k = [[self getValue:@"multi"] intValue] + 1 ;
        
        [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"multi"];
    }
    
    if([[self getValue:@"multi"] intValue] % 6 == 0)
    {
        [self performSelector:@selector(showAds) withObject:nil afterDelay:0.5];
    }
}

- (IBAction)didPressBack:(id)sender
{
    [multiSelection removeLastObject];
    
    NSMutableString * mutable = [NSMutableString new];
    
    for(NSString * string in multiSelection)
    {
        [mutable appendString:string];
    }
    
    emoText.text = mutable;
}

- (void)showAds
{
    if([[self infoPlist][@"showAds"] boolValue])
    {
        if(![[System getValue:@"adsInfo"][@"adsMob"] boolValue])
        {
            [[Ads sharedInstance] S_didShowFullAdsWithInfor:@{} andCompletion:^(BannerEvent event, NSError *error, id bannerAd) {
                switch (event)
                {
                    case AdsDone:
                    {
                        
                    }
                        break;
                    case AdsFailed:
                    {
                        
                    }
                        break;
                    case AdsWillPresent:
                    {
                        
                    }
                        break;
                    case AdsWillLeave:
                    {
                        
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
        else
        {
            if([System getValue:@"adsInfo"][@"fullBanner"])
            {
                [[Ads sharedInstance] G_didShowFullAdsWithInfor:@{@"host":self,@"adsId":[System getValue:@"adsInfo"][@"fullBanner"]/*,@"device":@""*/} andCompletion:^(BannerEvent event, NSError *error, id banner) {
                    
                    switch (event)
                    {
                        case AdsDone:
                            
                            break;
                        case AdsFailed:
                            
                            break;
                        default:
                            break;
                    }
                }];
            }
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        [self showSVHUD:@"Photo not saved, try again later" andOption:2];
    }
    else
    {
        [self showSVHUD:@"Done" andOption:1];
        
        [System addValue:(__bridge NSString*)contextInfo andKey:(__bridge NSString*)contextInfo];
        
        [collectionView reloadData];
    }
}

-(void)didChangeImagePosition:(CGRect)rect isBack:(BOOL)back
{
    UIImageView * temp = [[UIImageView alloc] initWithFrame:rect];
    temp.backgroundColor = [self.title isEqualToString:@"Fun"] ? [AVHexColor colorWithHexString:@"#DDEFFA"] : [UIColor clearColor];
    temp.image = tempImage;
    
    if(back)
    {
        [self.view addSubview:preview];
        [self.view addSubview:temp];
    }
    
    CGRect destination = [preview convertRect:preview.bounds toView:nil];
    destination.origin.y -= 64;
    
    [UIView animateWithDuration:0.3 animations:^{
        if(back)
        {
            temp.transform = [self translatedAndScaledTransformUsingViewRect:back ? destination : rect fromRect: back ? rect : destination];
        }
        else
        {
            preview.transform = [self translatedAndScaledTransformUsingViewRect:back ? destination : rect fromRect: back ? rect : destination];
        }
    }
                     completion:^(BOOL finished){
                         if(back)
                         {
                             [temp removeFromSuperview];
                             preview.image = tempImage;
                             preview.backgroundColor = [self.title isEqualToString:@"Fun"] ? [AVHexColor colorWithHexString:@"#DDEFFA"] : [UIColor clearColor];
                         }
                         else
                         {
                             [preview removeFromSuperview];
                             preview = [self returnImage:CGRectMake(15, (screenHeight - (screenWidth - (screenWidth * sideRatio)) - 30) / 2 - 15 , (screenWidth - (screenWidth * sideRatio)) - 30 , (screenWidth - (screenWidth * sideRatio)) - 30)];
                         }
                         self.navigationItem.leftBarButtonItem.enabled = !back;
                     }];
}

- (CGAffineTransform)translatedAndScaledTransformUsingViewRect:(CGRect)viewRect fromRect:(CGRect)fromRect
{
    CGSize scales = CGSizeMake(viewRect.size.width/fromRect.size.width, viewRect.size.height/fromRect.size.height);
    CGPoint offset = CGPointMake(CGRectGetMidX(viewRect) - CGRectGetMidX(fromRect), CGRectGetMidY(viewRect) - CGRectGetMidY(fromRect));
    return CGAffineTransformMake(scales.width, 0, 0, scales.height, offset.x, offset.y);
}

- (void)pulse:(UIView*)view toSize: (float) value withDuration:(float) duration
{
    [UIView animateWithDuration:duration
                     animations:^{
                         CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                         pulseAnimation.duration = duration;
                         pulseAnimation.toValue = [NSNumber numberWithFloat:value];;
                         pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                         pulseAnimation.autoreverses = YES;
                         pulseAnimation.repeatCount = 1;
                         [view.layer addAnimation:pulseAnimation forKey:nil];
                     }
                     completion:^(BOOL finished)
     {
     }];
}

- (NSString *)uuidString
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

@implementation UIImage (AverageColor)

- (UIColor *)averageColor {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] == 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

@end

