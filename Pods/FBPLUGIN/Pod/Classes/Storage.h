//
//  Storage.h
//  Pods
//
//  Created by thanhhaitran on 12/27/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Storage : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

+ (Storage*)shareInstance;


@end
