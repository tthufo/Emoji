//
//  System.m
//  Pods
//
//  Created by thanhhaitran on 12/27/15.
//
//

#import "System.h"

#import "Storage.h"

@implementation System

@synthesize key, value;

+ (BOOL)addSystem:(NSDictionary*)dict
{
    Storage *db = [Storage shareInstance];
    NSUInteger count = [[self getFormat:@"key=%@" argument:@[dict[@"key"]]] count];
    if (count > 0)
    {
        System *s = [[self getFormat:@"key=%@" argument:@[dict[@"key"]]] lastObject];
        s.value = [NSKeyedArchiver archivedDataWithRootObject:dict[@"value"]];
        [db saveContext];
        return NO;
    }
    
    System *b = [NSEntityDescription insertNewObjectForEntityForName:@"System" inManagedObjectContext: [db managedObjectContext]];
    
    if (dict[@"key"])
    {
        b.key = dict[@"key"];
    }
    
    if (dict[@"value"])
    {
        b.value = [NSKeyedArchiver archivedDataWithRootObject:dict[@"value"]];
    }
    
    [db saveContext];
    
    return YES;
}

+ (void)addValue:(id)value andKey:(NSString*)key
{
    NSDictionary * temp = [NSDictionary dictionaryWithObjectsAndKeys:key,@"key",value,@"value", nil];
    [self addSystem:temp];
}

+ (id)getValue:(NSString*)key
{
    System * s = [[self getFormat:@"key=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
    id result = [NSKeyedUnarchiver unarchiveObjectWithData:s.value];
    return  result;
}

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument
{
    Storage *db = [Storage shareInstance];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"System" inManagedObjectContext:[db managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    NSPredicate *p1 = [NSPredicate predicateWithFormat:format argumentArray:argument];
    [fr setPredicate:p1];
    NSArray *result = [[db managedObjectContext] executeFetchRequest:fr error:nil];
//    NSMutableArray * arr = [NSMutableArray new];
//    for(System * s in result)
//    {
//        [arr addObject:[NSKeyedUnarchiver unarchiveObjectWithData:s.value]];
//    }
    return result;
}

+ (void)removeValue:(NSString*)key
{
    Storage *db = [Storage shareInstance];
    System * s = [[self getFormat:@"key=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
    if(s)
    {
        [[db managedObjectContext] deleteObject:s];
    }
    [db saveContext];
}

+ (NSArray *)getAll
{
    Storage *db = [Storage shareInstance];
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"System" inManagedObjectContext:[db managedObjectContext]];
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:ed];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"key" ascending:YES];
    
    [fr setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *result = [[db managedObjectContext] executeFetchRequest:fr error:nil];
//    NSMutableArray * arr = [NSMutableArray new];
//    for(System * s in result)
//    {
//        [arr addObject:[NSKeyedUnarchiver unarchiveObjectWithData:s.value]];
//    }
    return result;
}

@end
