# LSMiniDB

**LSMiniDB** is a simple to use and minimalistic database. Easy to configure from code. All database operations (insert/select/update/delete) are performed with NSDictionary objects asynchronously on a background thread.

## Configuring database model and storage

```objc
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
```

## Usage examples

```objc
NSDictionary *user = @{ @"uuid" : [NSUUID UUID].UUIDString,
                        @"name" : @"John",
                        @"score" : @55,
                        @"date" : [NSDate new] };

// insert
[[LSMiniDB defaultInstance] insertObject:user table:@"user" completion:^{
    NSLog(@"inserted user");
}];

// select
[[LSMiniDB defaultInstance] selectObjectsFromTable:@"user" predicate:[NSPredicate predicateWithFormat:@"name == %@", @"John"] sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]] limit:5 completion:^(NSArray<NSDictionary *> *objects) {
    NSLog(@"selected users");
}];

// update
[[LSMiniDB defaultInstance] updateObject:user table:@"user" predicate:[NSPredicate predicateWithFormat:@"uuid == %@", user[@"uuid"]] completion:^{
    NSLog(@"updated user");
}];

// delete
[[LSMiniDB defaultInstance] deleteObjectsFromTable:@"user" predicate:[NSPredicate predicateWithFormat:@"uuid == %@", user[@"uuid"]] completion:^{
    NSLog(@"deleted user");
}];
```

More examples in sample project.

## License

LSMiniDB is available under the MIT license.
