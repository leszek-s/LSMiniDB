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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 LSMiniDB is a simple to use and minimalistic database. Easy to configure from code.
 All database operations (insert/select/update/delete) are performed with NSDictionary
 objects asynchronously on a background thread.
 */
@interface LSMiniDB : NSObject

/**
 Returns default instance.

 @return Default instance.
 */
+ (instancetype)defaultInstance;

/**
 Configures database with tables model and file name.

 @param model Model describing tables in the database.
 @param fileName Name of the file with the database.
 */
- (void)configureWithModel:(NSDictionary *)model fileName:(NSString *)fileName;

/**
 Inserts an object into specified table.

 @param object Object to insert.
 @param table Name of the table.
 @param completion Completion block.
 */
- (void)insertObject:(NSDictionary *)object table:(NSString *)table completion:(void (^)(void))completion;

/**
 Inserts many objects into specified table.

 @param objects Array of objects to insert.
 @param table Name of the table.
 @param completion Completion block.
 */
- (void)insertObjects:(NSArray<NSDictionary *> *)objects table:(NSString *)table completion:(void (^)(void))completion;

/**
 Reads all objects from specified table.

 @param table Name of the table.
 @param completion Completion block.
 */
- (void)selectObjectsFromTable:(NSString *)table completion:(void (^)(NSArray<NSDictionary *> *objects))completion;

/**
 Reads objects from specified table with optional predicate.

 @param table Name of the table.
 @param predicate Predicate used to find objects in the database.
 @param completion Completion block.
 */
- (void)selectObjectsFromTable:(NSString *)table predicate:(NSPredicate *)predicate completion:(void (^)(NSArray<NSDictionary *> *objects))completion;

/**
 Reads objects from specified table with optional predicate, sort descriptors and limit.

 @param table Name of the table.
 @param predicate Predicate used to find objects in the database.
 @param sortDescriptors Sort descriptors.
 @param limit Maximum number of objects to read.
 @param completion Completion block.
 */
- (void)selectObjectsFromTable:(NSString *)table predicate:(NSPredicate *)predicate sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit completion:(void (^)(NSArray<NSDictionary *> *objects))completion;

/**
 Updates object in specified table.

 @param object New object data.
 @param table Name of the table.
 @param predicate Predicate used to find the object in the database.
 @param completion Completion block.
 */
- (void)updateObject:(NSDictionary *)object table:(NSString *)table predicate:(NSPredicate *)predicate completion:(void (^)(void))completion;

/**
 Updates many objects in specified table.

 @param objects New objects data.
 @param table Name of the table.
 @param predicates Predicates used to find objects in the database.
 @param completion Completion block.
 */
- (void)updateObjects:(NSArray<NSDictionary *> *)objects table:(NSString *)table predicates:(NSArray<NSPredicate *> *)predicates completion:(void (^)(void))completion;

/**
 Deletes all objects from specified table.

 @param table Name of the table.
 @param completion Completion block.
 */
- (void)deleteObjectsFromTable:(NSString *)table completion:(void (^)(void))completion;

/**
 Deletes objects from specified table with optional predicate.

 @param table Name of the table.
 @param predicate Predicate used to find objects to delete.
 @param completion Completion block.
 */
- (void)deleteObjectsFromTable:(NSString *)table predicate:(NSPredicate *)predicate completion:(void (^)(void))completion;

@end
