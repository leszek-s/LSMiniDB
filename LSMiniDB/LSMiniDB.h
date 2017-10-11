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

@interface LSMiniDB : NSObject

+ (instancetype)defaultInstance;

- (void)configureWithModel:(NSDictionary *)model fileName:(NSString *)fileName;

- (void)insertObject:(NSDictionary *)object table:(NSString *)table completion:(void (^)(void))completion;

- (void)insertObjects:(NSArray<NSDictionary *> *)objects table:(NSString *)table completion:(void (^)(void))completion;

- (void)selectObjectsFromTable:(NSString *)table completion:(void (^)(NSArray<NSDictionary *> *objects))completion;

- (void)selectObjectsFromTable:(NSString *)table predicate:(NSPredicate *)predicate completion:(void (^)(NSArray<NSDictionary *> *objects))completion;

- (void)selectObjectsFromTable:(NSString *)table predicate:(NSPredicate *)predicate sortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors limit:(NSUInteger)limit completion:(void (^)(NSArray<NSDictionary *> *objects))completion;

- (void)updateObject:(NSDictionary *)object table:(NSString *)table predicate:(NSPredicate *)predicate completion:(void (^)(void))completion;

- (void)updateObjects:(NSArray<NSDictionary *> *)objects table:(NSString *)table predicates:(NSArray<NSPredicate *> *)predicates completion:(void (^)(void))completion;

- (void)deleteObjectsFromTable:(NSString *)table completion:(void (^)(void))completion;

- (void)deleteObjectsFromTable:(NSString *)table predicate:(NSPredicate *)predicate completion:(void (^)(void))completion;


@end
