//
//  NSObject+Category.h
//  Pods
//
//  Created by thanhhaitran on 12/21/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface NSObject (Extension_Category) <CLLocationManagerDelegate>

- (BOOL)isConnectionAvailable;

- (NSString *)uuidString;

- (NSDictionary*)infoPlist;

- (NSString *)deviceUUID;

- (NSInteger)currentDateInt;

- (NSDictionary *)appInfor;

- (void)addValue:(NSString*)value andKey:(NSString*)key;

- (NSString*)getValue:(NSString*)key;

- (void)removeValue:(NSString*)key;

- (void)clearAllValue;

- (void)modifyObject:(NSDictionary*)value andKey:(NSString*)key;

- (void)addObject:(NSDictionary*)value andKey:(NSString*)key;

- (NSDictionary*)getObject:(NSString*)key;

- (void)removeObject:(NSString*)key;

- (void)alert:(NSString *)title message:(NSString *)message;

- (void)showSVHUD:(NSString*)string andOption:(int)index;

- (void)hideSVHUD;

- (void)showToast:(NSString*)toast andPos:(int)pos;

- (void)initLocation;

- (NSDictionary *)currentLocation;

- (id)withView:(id)superView tag:(int)tag;

- (int)inDexOf:(UIView*)view andTable:(UITableView*)tableView;

@end

@interface NSDictionary (name)

- (NSMutableDictionary*)reFormat;

- (BOOL)responseForKey:(NSString *)name;

- (NSString*)responseForKind:(NSString*)name;

- (NSString*)getValueFromKey:(NSString *)name;

- (NSString*)responseForKind:(NSString*)name andOption:(NSString*)placeHolder;

- (NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint;

- (BOOL)responseForKindOfClass:(NSString *)name andTarget:(NSString*)target;

- (NSDictionary*)dictionaryWithPlist:(NSString*)pList;

@end

@interface NSNotificationCenter (UniqueNotif)

- (void)addUniqueObserver:(id)observer selector:(SEL)selector name:(NSString *)name object:(id)object;

@end


@interface UILabel (UILabelDynamicHeight)

- (CGSize)sizeOfLabel;

- (CGSize)sizeOfMultiLineLabel;

@end

@interface NSMutableArray (utility)

- (void)selfDeleteObject;

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

@end

@interface NSArray (OrderedDuplicateElimination)

- (NSArray *)arrayByEliminatingDuplicatesMaintainingOrder;

- (NSMutableArray*)arrayByMergeAndDeduplication:(NSArray*)total;

- (NSString *)bv_jsonStringWithPrettyPrint:(BOOL)prettyPrint;

- (NSArray*)arrayWithPlist:(NSString*)name;

- (NSArray*)arrayWithMutable;

@end

@interface UIView (Border)

- (UIImage *)pb_takeSnapshot;

- (UIView *)withBorder:(NSDictionary *)dict;

- (UIView*)withShadow;

- (UIView*)withShadow:(UIColor*)hext;

- (void)setHeight:(CGFloat)height animated:(BOOL)animate;

- (void)bounce:(float)bounceFactor;

@end

@interface UIImage (Scale)

- (UIImage *)imageScaledToQuarter;

- (UIImage *)imageScaledToHalf;

- (UIImage *)imageScaledToScale:(CGFloat)scale;

- (UIImage *)imageScaledToScale:(CGFloat)scale
       withInterpolationQuality:(CGInterpolationQuality)quality;

- (UIImage*)imageWithBrightness:(CGFloat)brightnessFactor;

- (UIImage*)imageWithImage:(CGSize)newSize;

@end

@interface NSString (Contains)

- (CGFloat)didConfigHeight:(CGFloat)fontSize andDistance:(CGFloat)distance andExtra:(CGFloat)extra;

- (BOOL)myContainsString:(NSString*)other;

- (NSString*)specialDateFromTimeStamp;

- (NSString*)specialDateAndTimeFromTimeStamp;

- (NSString*)dateFromTimeStamp;

- (NSString*)dateAndTimeFromTimeStamp;

- (NSString*)dateFromTimeStamp:(NSString*)format;

- (NSString*)normalizeDateTime:(int)position;

@end

@interface NSMutableDictionary (Additions)

- (void)removeObjectForKeyPath: (NSString *)keyPath;

@end

@interface UITableView (extras)

- (void)cellVisible;

- (void)didScrolltoNearTop:(BOOL)animate;

- (void)didScrolltoTop:(BOOL)animate;

- (void)didScrolltoBottom:(BOOL)animate;

- (void)reloadDataWithAnimation:(BOOL)animate;

@end

@interface NSDate (extension)

- (NSDate *)addDays:(NSInteger)days toDate:(NSDate *)originalDate;

- (NSString *)stringWithFormat:(NSString *)format;

- (BOOL)isPastTime:(NSString*)theDate;

@end

@interface CALayer(XibConfiguration)

@property(nonatomic, assign) UIColor* borderUIColor;

@end

@interface NSString (RemoveEmoji)

- (NSString*)encodeUrl;

- (BOOL)isIncludingEmoji;

- (instancetype)stringByRemovingEmoji;

- (instancetype)removedEmojiString __attribute__((deprecated));

@end