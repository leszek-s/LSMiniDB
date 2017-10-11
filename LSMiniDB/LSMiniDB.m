// Copyright (c) 2017 Leszek S
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LSMiniDB.h"

@interface LSMiniDB ()

@property (strong, nonatomic) NSDictionary *databaseModel;
@property (strong, nonatomic) NSString *databaseFileName;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation LSMiniDB

+ (instancetype)defaultInstance
{
    static id defaultInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [self new];
    });
    
    return defaultInstance;
}

- (void)configureWithModel:(NSDictionary *)model fileName:(NSString *)fileName
{
    self.databaseModel = model;
    self.databaseFileName = fileName;
}

- (NSManagedObjectModel *)coreDataModelWithTables:(NSDictionary *)tables
{
    NSManagedObjectModel *model = [NSManagedObjectModel new];
    
    NSMutableArray *entities = [NSMutableArray new];
    for (NSString *table in tables)
    {
        NSEntityDescription *entity = [NSEntityDescription new];
        entity.name = table;
        
        NSDictionary *columns = tables[table];
        NSMutableArray *attributes = [NSMutableArray new];
        for (NSString *column in tables[table])
        {
            NSNumber *type = columns[column];
            NSAttributeDescription *attribute = [NSAttributeDescription new];
            attribute.name = column;
            attribute.attributeType = type.unsignedIntegerValue;
            attribute.optional = YES;
            [attributes addObject:attribute];
        }
        entity.properties = [attributes copy];
        [entities addObject:entity];
    }
    
    model.entities = [entities copy];
    
    return model;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel)
    {
        return _managedObjectModel;
    }
    _managedObjectModel = [self coreDataModelWithTables:self.databaseModel];
    return _managedObjectModel;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
    {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:self.databaseFileName];
    NSError *error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        BOOL migrationError = [error.domain isEqual:NSCocoaErrorDomain] && (error.code == NSPersistentStoreIncompatibleVersionHashError || error.code == NSMigrationMissingSourceModelError);
        
        if (!migrationError)
        {
            NSLog(@"Unresolved database error %@", error);
            abort();
        }
        
        NSLog(@"Removing incompatible database");
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            NSLog(@"Unresolved database error %@", error);
            abort();
        }
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator)
    {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext)
    {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved database error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSArray<NSManagedObject *> *)fetchObjectsWithEntityName:(NSString *)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [fetchRequest setFetchLimit:limit];
    return [[NSArray alloc] initWithArray:[self.managedObjectContext executeFetchRequest:fetchRequest error:nil]];
}

- (void)insertObject:(NSDictionary *)object table:(NSString *)table completion:(void (^)(void))completion
{
    [self insertObjects:object ? @[object] : @[] table:table completion:completion];
}

- (void)insertObjects:(NSArray<NSDictionary *> *)objects table:(NSString *)table completion:(void (^)(void))completion
{
    [self.managedObjectContext performBlock:^{
        for (NSDictionary *object in objects)
        {
            NSManagedObject *dbObject = [NSEntityDescription insertNewObjectForEntityForName:table inManagedObjectContext:self.managedObjectContext];
            for (NSString *key in dbObject.entity.attributesByName.allKeys)
            {
                [dbObject setValue:object[key] forKey:key];
            }
        }
        [self saveContext];
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

- (void)selectObjectsFromTable:(NSString *)table completion:(void (^)(NSArray<NSDictionary *> *objects))completion
{
    [self selectObjectsFromTable:table predicate:nil sortDescriptors:nil limit:0 completion:completion];
}

- (void)selectObjectsFromTable:(NSString *)table predicate:(NSPredicate *)predicate completion:(void (^)(NSArray<NSDictionary *> *objects))completion
{
    [self selectObjectsFromTable:table predicate:predicate sortDescriptors:nil limit:0 completion:completion];
}

- (void)selectObjectsFromTable:(NSString *)table predicate:(NSPredicate *)predicate sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit completion:(void (^)(NSArray<NSDictionary *> *objects))completion
{
    [self.managedObjectContext performBlock:^{
        NSArray *dbObjects = [self fetchObjectsWithEntityName:table predicate:predicate sortDescriptors:sortDescriptors limit:limit];
        NSMutableArray *objects = [NSMutableArray new];
        
        for (NSManagedObject *dbObject in dbObjects)
        {
            NSArray *keys = dbObject.entity.attributesByName.allKeys;
            NSDictionary *object = [dbObject dictionaryWithValuesForKeys:keys];
            [objects addObject:object];
        }
        
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([objects copy]);
            });
        }
    }];
}

- (void)updateObject:(NSDictionary *)object table:(NSString *)table predicate:(NSPredicate *)predicate completion:(void (^)(void))completion
{
    [self updateObjects:object ? @[object] : @[] table:table predicates:predicate ? @[predicate] : @[] completion:completion];
}

- (void)updateObjects:(NSArray<NSDictionary *> *)objects table:(NSString *)table predicates:(NSArray<NSPredicate *> *)predicates completion:(void (^)(void))completion
{
    [self.managedObjectContext performBlock:^{
        if (objects.count == predicates.count)
        {
            for (NSInteger i = 0; i < objects.count; i++)
            {
                NSDictionary *object = objects[i];
                NSPredicate *predicate = predicates[i];
                
                NSManagedObject *dbObject = [self fetchObjectsWithEntityName:table predicate:predicate sortDescriptors:nil limit:1].firstObject;
                for (NSString *key in dbObject.entity.attributesByName.allKeys)
                {
                    [dbObject setValue:object[key] forKey:key];
                }
            }
            [self saveContext];
        }
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

- (void)deleteObjectsFromTable:(NSString *)table completion:(void (^)(void))completion
{
    [self deleteObjectsFromTable:table predicate:nil completion:completion];
}

- (void)deleteObjectsFromTable:(NSString *)table predicate:(NSPredicate *)predicate completion:(void (^)(void))completion
{
    [self.managedObjectContext performBlock:^{
        NSArray *dbObjects = [self fetchObjectsWithEntityName:table predicate:predicate sortDescriptors:nil limit:0];
        
        for (NSManagedObject *dbObject in dbObjects)
        {
            [self.managedObjectContext deleteObject:dbObject];
        }
        [self saveContext];
        if (completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    }];
}

@end
