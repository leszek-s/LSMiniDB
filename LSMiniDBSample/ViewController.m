//
//  ViewController.m
//  LSMiniDBSample
//
//  Created by Leszek on 10.10.2017.
//  Copyright © 2017 LS. All rights reserved.
//

#import "ViewController.h"
#import "LSMiniDB.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureDatabase];
}

- (void)configureDatabase
{
    NSDictionary *userTable = @{ @"uuid" : @(NSStringAttributeType),
                                 @"name" : @(NSStringAttributeType),
                                 @"score" : @(NSInteger32AttributeType),
                                 @"date" : @(NSDateAttributeType) };
    
    NSDictionary *eventTable = @{ @"name" : @(NSStringAttributeType),
                                  @"date" : @(NSDateAttributeType) };
    
    NSDictionary *model = @{ @"user" : userTable,
                             @"event" : eventTable };
    
    [[LSMiniDB defaultInstance] configureWithModel:model fileName:@"database.db"];
}

- (NSDictionary *)randomUser
{
    NSString *name = @[ @"John", @"Kate"][arc4random_uniform(2)];
    NSNumber *score = @(arc4random_uniform(101));
    NSDate *date = [[NSDate new] dateByAddingTimeInterval:-arc4random_uniform(3600)];
    
    NSDictionary *user = @{ @"uuid" : [NSUUID UUID].UUIDString,
                            @"name" : name,
                            @"score" : score,
                            @"date" : date };
    return user;
}

- (IBAction)insertUserAction:(id)sender
{
    [[LSMiniDB defaultInstance] insertObject:[self randomUser] table:@"user" completion:^{
        NSLog(@"inserted user");
    }];
}

- (IBAction)insertUsersAction:(id)sender
{
    [[LSMiniDB defaultInstance] insertObjects:@[[self randomUser], [self randomUser]] table:@"user" completion:^{
        NSLog(@"inserted users");
    }];
}

- (IBAction)selectUserAction:(id)sender
{
    [[LSMiniDB defaultInstance] selectObjectsFromTable:@"user" predicate:[NSPredicate predicateWithFormat:@"name == %@", @"John"] sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]] limit:1 completion:^(NSArray<NSDictionary *> *objects) {
        if (objects.count > 0)
        {
            NSLog(@"selected user with name John and highest score:\n%@", objects);
        }
        else
        {
            NSLog(@"no John in database");
        }
    }];
}

- (IBAction)selectUsersAction:(id)sender
{
    [[LSMiniDB defaultInstance] selectObjectsFromTable:@"user" completion:^(NSArray<NSDictionary *> *objects) {
        NSLog(@"selected users:\n%@", objects);
    }];
}

- (IBAction)updateUserAction:(id)sender
{
    [[LSMiniDB defaultInstance] selectObjectsFromTable:@"user" completion:^(NSArray<NSDictionary *> *objects) {
        NSMutableDictionary *user = [objects.firstObject mutableCopy];
        user[@"score"] = @100;
        
        [[LSMiniDB defaultInstance] updateObject:user table:@"user" predicate:[NSPredicate predicateWithFormat:@"uuid == %@", user[@"uuid"]] completion:^{
            NSLog(@"updated user");
        }];
    }];
}

- (IBAction)updateUsersAction:(id)sender
{
    [[LSMiniDB defaultInstance] selectObjectsFromTable:@"user" completion:^(NSArray<NSDictionary *> *objects) {
        NSMutableArray *users = [NSMutableArray new];
        NSMutableArray *predicates = [NSMutableArray new];
        for (NSDictionary *object in objects)
        {
            NSMutableDictionary *user = [object mutableCopy];
            user[@"score"] = @([user[@"score"] integerValue] + 10);
            [users addObject:user];
            [predicates addObject:[NSPredicate predicateWithFormat:@"uuid == %@", user[@"uuid"]]];
        }
        
        [[LSMiniDB defaultInstance] updateObjects:users table:@"user" predicates:predicates completion:^{
            NSLog(@"updated users");
        }];
    }];
}

- (IBAction)deleteUserAction:(id)sender
{
    [[LSMiniDB defaultInstance] selectObjectsFromTable:@"user" completion:^(NSArray<NSDictionary *> *objects) {
        NSDictionary *user = objects.firstObject;
        [[LSMiniDB defaultInstance] deleteObjectsFromTable:@"user" predicate:[NSPredicate predicateWithFormat:@"uuid == %@", user[@"uuid"]] completion:^{
            NSLog(@"deleted user");
        }];
    }];
}

- (IBAction)deleteUsersAction:(id)sender
{
    [[LSMiniDB defaultInstance] deleteObjectsFromTable:@"user" completion:^{
        NSLog(@"deleted users");
    }];
}

@end
