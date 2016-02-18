//
//  NSObject+Category.m
//  Pods
//
//  Created by thanhhaitran on 12/21/15.
//
//

#import "NSObject+Category.h"

#import "AVHexColor.h"

#import "SVProgressHUD.h"

#import "UIView+Toast.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define iOS7_0 @"7.0"

@implementation NSObject (Extension_Category)

CLLocationManager * locationManager;

- (NSString *)deviceUUID
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSDictionary *)appInfor
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    return @{@"majorVersion":majorVersion,@"minorVersion":minorVersion};
}

-(NSInteger)currentDateInt
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"ddMMyyyy"];
    NSDate *date = [NSDate date];
    CFAbsoluteTime at = [date timeIntervalSinceReferenceDate];
    CFTimeZoneRef tz = CFTimeZoneCopySystem();
    SInt32 WeekdayNumber = CFAbsoluteTimeGetDayOfWeek(at, tz);
    return WeekdayNumber;
}

- (void)initLocation
{
    if(!locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [locationManager requestWhenInUseAuthorization];
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        
        [locationManager startUpdatingLocation];
        [locationManager stopUpdatingLocation];
    }
}

- (NSDictionary *)currentLocation
{
    if(!locationManager) return nil;
    if(![CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        else
        {
            [self alert:@"Alert" message:@"Failed to get your location, please go to Settings to check your Location Services"];
        }
        return nil;
    }
    NSLog(@"_%@",@{@"lat":@(locationManager.location.coordinate.longitude),@"lng":@(locationManager.location.coordinate.latitude)});
    return @{@"lat":@(locationManager.location.coordinate.longitude),@"lng":@(locationManager.location.coordinate.latitude)};
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"Moved to location : %@",[newLocation description]);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self alert:@"Alert" message:@"Failed to get your location, please go to Settings to check your Location Services"];
}

- (void)addValue:(NSString*)value andKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (NSString*)getValue:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)removeValue:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void)modifyObject:(NSDictionary*)value andKey:(NSString*)key
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:key]];
    for(NSString * key in value.allKeys)
    {
        BOOL isFound = NO;
        for(NSString * k in dic.allKeys)
        {
            if([k isEqualToString:key])
            {
                dic[k] = value[key];
                isFound = YES;
                break;
            }
        }
        if(!isFound)
        {
            dic[key] = value[key];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:key];
}

- (void)addObject:(NSDictionary*)value andKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (NSDictionary*)getObject:(NSString*)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)removeObject:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

- (void)clearAllValue
{
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
}

- (void)alert:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [alert show];
}

- (void)showToast:(NSString*)toast andPos:(int)pos
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window makeToast:toast duration:2 position:pos == 0 ? CSToastPositionBottom : pos == 1 ? CSToastPositionCenter : CSToastPositionTop];
}

- (void)showSVHUD:(NSString*)string andOption:(int)index
{
    switch (index)
    {
        case 0:
        {
            [SVProgressHUD showWithStatus:string maskType:SVProgressHUDMaskTypeGradient];
        }
            break;
        case 1:
            [SVProgressHUD showSuccessWithStatus:string];
            break;
        case 2:
            [SVProgressHUD showErrorWithStatus:string];
            break;
        default:
            break;
    }
}

- (void)hideSVHUD
{
    [SVProgressHUD dismiss];
}

- (id)withView:(id)superView tag:(int)tag
{
    return [superView viewWithTag:tag];
}

- (int)inDexOf:(UIView*)view andTable:(UITableView*)tableView
{
    CGPoint center = view.center;
    CGPoint rootViewPoint = [view.superview convertPoint:center toView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:rootViewPoint];
    return (int)indexPath.row;
}

@end

@implementation NSDictionary (name)

- (NSMutableDictionary*)reFormat
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:self];
    for(NSString * key in dict.allKeys)
    {
        if([dict[key] isKindOfClass:[NSDictionary class]])
        {
            dict[key] = [((NSDictionary*)dict[key]) reFormat];
        }
        else if([dict[key] isKindOfClass:[NSArray class]])
        {
            dict[key] = [((NSArray*)dict[key]) arrayWithMutable];
        }
        else
        {
            if(dict[key] == [NSNull null])
            {
                dict[key] = @"";
            }
        }
    }
    return dict;
}

-(NSDictionary*)dictionaryWithPlist:(NSString*)pList
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:pList ofType:@"plist"];
    return [self initWithContentsOfFile:plistPath];
}

- (BOOL)responseForKey:(NSString *)name
{
    return ([self objectForKey:name] && [self objectForKey:name] != [NSNull null]);
}

- (NSString*)responseForKind:(NSString*)name
{
    return [self responseForKey:name] ? [self[name] isKindOfClass:[NSString class]] ? self[name] : [self[name] stringValue] : @"Wrong key";
}

- (NSString*)responseForKind:(NSString*)name andOption:(NSString*)placeHolder
{
    return [self responseForKey:name] ? [self[name] isKindOfClass:[NSString class]] ? self[name] : [self[name] stringValue] : placeHolder ? placeHolder : name;
}

- (NSString*)getValueFromKey:(NSString *)name
{
    if(!self[name])
    {
        return @"";
    }
    if(self[name] == [NSNull null])
    {
        return @"";
    }
    if([self[name] isKindOfClass:[NSString class]])
    {
        return self[name];
    }
    else
    {
        return [self[name] stringValue];
    }
    return nil;
}

- (BOOL)responseForKindOfClass:(NSString *)name andTarget:(NSString*)target
{
    if([self[name] isKindOfClass:[NSString class]])
    {
        if([self[name] isEqualToString:target])
            return YES;
        else
            return NO;
    }
    else
    {
        if([self[name] isEqualToNumber:@([target intValue])])
            return YES;
        else
            return NO;
    }
    return NO;
}

- (NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    if (! jsonData)
    {
        //NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    }
    else
    {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end


@implementation NSNotificationCenter (UniqueNotif)

- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:name object:object];
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];
}
@end



@implementation UILabel (UILabelDynamicHeight)

- (CGSize)sizeOfLabel
{
    return  [self.text sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:self.font.fontName size:self.font.pointSize]}];
}

- (CGSize)sizeOfMultiLineLabel
{
    NSAssert(self, @"UILabel was nil");
    NSString *aLabelTextString = [self text];
    UIFont *aLabelFont = [self font];
    CGFloat aLabelSizeWidth = self.frame.size.width;
    if (SYSTEM_VERSION_LESS_THAN(iOS7_0))
    {
        return [aLabelTextString sizeWithFont:aLabelFont
                            constrainedToSize:CGSizeMake(aLabelSizeWidth, MAXFLOAT)
                                lineBreakMode:NSLineBreakByWordWrapping];
    }
    else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS7_0))
    {
        return [aLabelTextString boundingRectWithSize:CGSizeMake(aLabelSizeWidth, MAXFLOAT)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{
                                                        NSFontAttributeName : aLabelFont
                                                        }
                                              context:nil].size;
    }
    return [self bounds].size;
}

@end

@implementation NSMutableArray (utility)

- (void)selfDeleteObject
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(id  dict in self)
    {
        if(![dict isKindOfClass:[NSDictionary class]])
        {
            [arr addObject:dict];
            continue;
        }
        BOOL isEmpty = YES;
        
        for(NSString * value in ((NSDictionary*)dict).allValues)
        {
            if(value && value.length != 0)
            {
                isEmpty = NO;
                break;
            }
        }
        if(isEmpty)
        {
            [arr addObject:dict];
        }
    }
    [self removeObjectsInArray:arr];
}

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    if (fromIndex < toIndex) {
        toIndex--;
    }
    
    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end


@implementation NSArray (OrderedDuplicateElimination)

- (NSArray *)arrayByEliminatingDuplicatesMaintainingOrder
{
    NSMutableSet *addedObjects = [NSMutableSet set];
    NSMutableArray *result = [NSMutableArray array];
    for (id obj in self) {
        if (![addedObjects containsObject:obj]) {
            [result addObject:obj];
            [addedObjects addObject:obj];
        }
    }
    return result;
}

- (NSMutableArray*)arrayByMergeAndDeduplication:(NSArray*)total
{
    [total[0] addObjectsFromArray:total[1]];
    
    NSMutableArray * ar3 = [total[1] arrayByEliminatingDuplicatesMaintainingOrder];
    
    NSMutableArray * deleteElement = [@[] mutableCopy];
    
    for(NSDictionary * string3 in ar3)
    {
        BOOL found = NO;
        for(NSDictionary * string2 in total[1])
        {
            if([string3[@"id"] isEqualToString:string2[@"id"]])
            {
                found = YES;
                break;
            }
        }
        if(!found)
        {
            [deleteElement addObject:string3];
        }
    }
    
    [ar3 removeObjectsInArray:deleteElement];
    
    return ar3;
}

-(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        //        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

-(NSArray*)arrayWithPlist:(NSString*)name
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:name ofType:@"plist"];
    return [self initWithContentsOfFile:plistPath];
}

-(NSArray*)arrayWithMutable
{
    NSMutableArray * arr = [NSMutableArray new];
    for(id objc in self)
    {
        if([objc isKindOfClass:[NSDictionary class]])
        {
            [arr addObject:[objc reFormat]];
        }
        else if([objc isKindOfClass:[NSArray class]])
        {
            [arr addObject:[objc arrayWithMutable]];
        }
        else if (objc == [NSNull null])
        {
            [arr addObject:@""];
        }
        else
        {
            [arr addObject:objc];
        }
    }
    return arr;
}

@end


@implementation UIView (Border)

- (UIImage *)pb_takeSnapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIView *)withBorder:(NSDictionary *)dict
{
    self.layer.borderColor =  ![dict responseForKey:@"Bcolor"] ? [dict responseForKey:@"Bhex"] ? [AVHexColor colorWithHexString:dict[@"Bhex"]].CGColor : [UIColor clearColor].CGColor : ((UIColor*)dict[@"Bcolor"]).CGColor;
    self.layer.cornerRadius = [dict responseForKey:@"Bcorner"] ? [dict[@"Bcorner"] floatValue] : 0;
    self.layer.borderWidth =  [dict responseForKey:@"Bwidth"] ? [dict[@"Bwidth"] floatValue] : 0;
    self.clipsToBounds = YES;
    if([dict responseForKey:@"Bground"])
        self.backgroundColor = ([dict responseForKey:@"Bground"] && [dict[@"Bground"] isKindOfClass:[NSString class]]) ? [AVHexColor colorWithHexString:dict[@"Bground"]] : ((UIColor*)dict[@"Bground"]);
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.userInteractionEnabled = YES;
    
    return self;
}

-(UIView*)withShadow
{
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(1.0f,3.0f);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = .8f;
    self.layer.shadowColor = [AVHexColor colorWithHexString:@"#2B292A"].CGColor;
    return self;
}

-(UIView*)withShadow:(UIColor*)hext
{
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(1.0f,3.0f);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = .8f;
    self.layer.shadowColor = hext.CGColor;
    return self;
}

- (void)setHeight:(CGFloat)height animated:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    CGRect f = self.frame;
    f.size.height = height;
    self.frame = f;
    if (animated)
    {
        [UIView commitAnimations];
    }
}

+ (CAKeyframeAnimation*)dockBounceAnimationWithViewHeight:(CGFloat)viewHeight
{
    NSUInteger const kNumFactors    = 22;
    CGFloat const kFactorsPerSec    = 30.0f;
    CGFloat const kFactorsMaxValue  = 128.0f;
    CGFloat factors[kNumFactors]    = {0,  60, 83, 100, 114, 124, 128, 128, 124, 114, 100, 83, 60, 32, 0, 0, 18, 28, 32, 28, 18, 0};
    
    NSMutableArray* transforms = [NSMutableArray array];
    
    for(NSUInteger i = 0; i < kNumFactors; i++)
    {
        CGFloat positionOffset  = factors[i] / kFactorsMaxValue * viewHeight;
        CATransform3D transform = CATransform3DMakeTranslation(0.0f, -positionOffset, 0.0f);
        
        [transforms addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.repeatCount           = 1;
    animation.duration              = kNumFactors * 1.0f/kFactorsPerSec;
    animation.fillMode              = kCAFillModeForwards;
    animation.values                = transforms;
    animation.removedOnCompletion   = YES;
    animation.autoreverses          = NO;
    
    return animation;
}

- (void)bounce:(float)bounceFactor
{
    CGFloat midHeight = self.frame.size.height * bounceFactor;
    CAKeyframeAnimation* animation = [[self class] dockBounceAnimationWithViewHeight:midHeight];
    [self.layer addAnimation:animation forKey:@"bouncing"];
}

@end

@implementation UIImage (Scale)

- (UIImage *)imageScaledToQuarter
{
    return [self imageScaledToScale:0.25f withInterpolationQuality:kCGInterpolationHigh];
}

- (UIImage *)imageScaledToHalf
{
    return [self imageScaledToScale:0.5f withInterpolationQuality:kCGInterpolationHigh];
}

- (UIImage *)imageScaledToScale:(CGFloat)scale
{
    return [self imageScaledToScale:scale withInterpolationQuality:kCGInterpolationHigh];
}

- (UIImage *)imageScaledToScale:(CGFloat)scale withInterpolationQuality:(CGInterpolationQuality)quality
{
    UIGraphicsBeginImageContextWithOptions(self.size, YES, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*) imageWithBrightness:(CGFloat)brightnessFactor {
    
    if ( brightnessFactor == 0 ) {
        return self;
    }
    
    CGImageRef imgRef = [self CGImage];
    
    size_t width = CGImageGetWidth(imgRef);
    size_t height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * width;
    size_t totalBytes = bytesPerRow * height;
    
    //Allocate Image space
    uint8_t* rawData = malloc(totalBytes);
    
    //Create Bitmap of same size
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //Draw our image to the context
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    
    //Perform Brightness Manipulation
    for ( int i = 0; i < totalBytes; i += 4 ) {
        
        uint8_t* red = rawData + i;
        uint8_t* green = rawData + (i + 1);
        uint8_t* blue = rawData + (i + 2);
        
        *red = MIN(255,MAX(0,roundf(*red + (*red * brightnessFactor))));
        *green = MIN(255,MAX(0,roundf(*green + (*green * brightnessFactor))));
        *blue = MIN(255,MAX(0,roundf(*blue + (*blue * brightnessFactor))));
        
    }
    
    //Create Image
    CGImageRef newImg = CGBitmapContextCreateImage(context);
    
    //Release Created Data Structs
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    free(rawData);
    
    //Create UIImage struct around image
    UIImage* image = [UIImage imageWithCGImage:newImg];
    
    //Release our hold on the image
    CGImageRelease(newImg);
    
    //return new image!
    return image;
}

- (UIImage*)imageWithImage:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

@implementation NSString (Contains)

- (CGFloat)didConfigHeight:(CGFloat)fontSize andDistance:(CGFloat)distance andExtra:(CGFloat)extra
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    CGFloat pointSize = fontSize;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:pointSize],
                                 NSParagraphStyleAttributeName: paragraphStyle};
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width - distance;
    
    CGRect titleBounds = [@"name" boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
    CGRect bodyBounds = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
    
    if (self.length == 0)
    {
        return 0.0;
    }
    
    CGFloat height = CGRectGetHeight(titleBounds);
    height += CGRectGetHeight(bodyBounds);
    height += extra;
    
    if (height < 50)
    {
        height = 50;
    }
    
    return height;
}

- (BOOL)myContainsString:(NSString*)other
{
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

- (BOOL)containsString:(NSString *)str
{
    return [self myContainsString:str];
}

-(NSString*)specialDateFromTimeStamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:self];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    return [dateFormatter stringFromDate:dateFromString];
}

-(NSString*)specialDateAndTimeFromTimeStamp
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:self];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss a"];
    return [dateFormatter stringFromDate:dateFromString];
}

-(NSString*)dateAndTimeFromTimeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    return [dateFormatter stringFromDate:date];
}

-(NSString*)dateFromTimeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    return [dateFormatter stringFromDate:date];
}

-(NSString*)dateFromTimeStamp:(NSString*)format
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:format];
    
    return [dateFormatter stringFromDate:date];
}

-(NSString*)normalizeDateTime:(int)position//:(NSString*)dateTime
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZZ"];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZZ"];
    
    //df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString *result = [df stringFromDate:[dateFormatter dateFromString:self]];
    
    NSString * final = [result componentsSeparatedByString:@" "][position];
    
    return final;
}

@end

@implementation NSMutableDictionary (Additions)

- (void)removeObjectForKeyPath: (NSString *)keyPath
{
    NSArray * keyPathElements = [keyPath componentsSeparatedByString:@"."];
    NSUInteger numElements = [keyPathElements count];
    NSString * keyPathHead = [[keyPathElements subarrayWithRange:(NSRange){0, numElements - 1}] componentsJoinedByString:@"."];
    NSMutableDictionary * tailContainer = [self valueForKeyPath:keyPathHead];
    [tailContainer removeObjectForKey:[keyPathElements lastObject]];
}

@end

@implementation UITableView (extras)

- (void)cellVisible
{
    [self reloadData];
    for(UITableViewCell * cell in self.visibleCells)
    {
        for(UIView * view in cell.contentView.subviews)
        {
            view.hidden = NO;
        }
    }
}

- (void)didScrolltoBottom:(BOOL)animate
{
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([self numberOfRowsInSection:0] - 1) inSection:0];
    [self scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didScrolltoTop:(BOOL)animate
{
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didScrolltoNearTop:(BOOL)animate
{
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)reloadDataWithAnimation:(BOOL)animate
{
    if(animate)
    {
        [UIView transitionWithView: self
                          duration: 0.2f
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        animations: ^(void)
         {
             [self reloadData];
         }
                        completion: ^(BOOL isFinished){}];
    }
    else
    {
        [self reloadData];
    }
}
@end

@implementation NSDate (extension)

- (NSDate *)addDays:(NSInteger)days toDate:(NSDate *)originalDate
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:originalDate options:0];
}

- (NSString *)stringWithFormat:(NSString *)format
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    return [df stringFromDate:self];
}

- (BOOL)isPastTime:(NSString*)theDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy"];
    NSDate *newDate = [df dateFromString:theDate];
    
    NSComparisonResult result;
    
    result = [self compare:newDate];
    
    if(result==NSOrderedAscending)
        return NO;
    else if(result==NSOrderedDescending)
        return YES;
    else
        return NO;
}

@end

@implementation CALayer(XibConfiguration)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end