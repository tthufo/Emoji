//
//  System.h
//  Pods
//
//  Created by thanhhaitran on 12/27/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface System : NSManagedObject

@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSData *value;

+ (void)addValue:(id)value andKey:(NSString*)key;

+ (id)getValue:(NSString*)key;

+ (void)removeValue:(NSString*)key;

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument;

+ (NSArray*)getAll;

@end

NS_ASSUME_NONNULL_END
