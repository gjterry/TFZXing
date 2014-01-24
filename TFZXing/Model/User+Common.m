//
//  User+Common.m
//  RocheLearnCenter
//
//  Created by Terry  on 13-7-16.
//  Copyright (c) 2013年 ED. All rights reserved.
//
static NSString *const CDENUser = @"User";

#import "NSJSONSerialization+RFKit.h"
#import "DataStack.h"
#import "User+Common.h"

@implementation User (Common)
+ (User *)userWithID:(NSString *)user_id createIfNotExist:(BOOL)creatIfNotExist {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDENUser];
    request.predicate = [NSPredicate predicateWithFormat:@"user_id = %@", user_id];
    
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    if (e) dout_error(@"%@", e);
    
    if (results.count == 1) {
        return [results firstObject];
    }
    else if (results.count == 0) {
        if (creatIfNotExist) {
            User *obj = [NSEntityDescription insertNewObjectForEntityForName:CDENUser inManagedObjectContext:[DataStack sharedInstance].context];
            obj.user_id = user_id;
            return obj;
        }
    }
    else {
        RFAssert(false, @"存在多个UID相同的Entity");
    }
    return nil;
}

+ (User *)currentUserInstance {
    NSError *e = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDENUser];
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results.count == 0?nil:results[0];
}

- (NSArray *)teamIDToArray {
    return [NSJSONSerialization JSONObjectWithString:self.team_id usingEncoding:NSUTF8StringEncoding allowLossyConversion:YES options:0 error:Nil];
}

+ (void)deleteUsers {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDENUser];
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:nil];
    for (User *aUser in results) {
        [[DataStack sharedInstance].context deleteObject:aUser];
    }
}

+ (BOOL)userChangedWithID:(NSString *)userID {
    User *currentUser = [User currentUserInstance];
    if (currentUser && ![currentUser.user_id isEqualToString:userID])
        return YES;
    return NO;
}

- (NSArray *)fetchMyDepartmentInfo:(NSArray *)source {
    NSMutableArray *info = [NSMutableArray arrayWithCapacity:0];
    [[self teamIDToArray]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *teamID = (NSString *)obj;
        NSArray *temp = [source filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            NSDictionary *dict = (NSDictionary *)evaluatedObject;
            __block BOOL exist = NO;
            [dict[@"children"]enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary *infoDict = (NSDictionary *)obj;
                if ([teamID isEqualToString:infoDict[@"_id"]]) {
                    exist = *stop = YES;
                }
            }];
            return exist;
        }]];
        if (temp.count > 0) {
            [temp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                id BUObj = obj;
                NSArray *array = [temp[idx][@"children"]filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    return [teamID isEqualToString:evaluatedObject[@"_id"]];
                }]];
                if (array.count > 0) {
                    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:obj];
                        [dict setObject:BUObj[@"_id"] forKey:@"bu_id"];
                        if (BUObj[@"skin_url"] && [BUObj[@"skin_url"]length] > 0) {
                            [dict setObject:BUObj[@"skin_url"] forKey:@"skin_url"];
                        }
                        [arr addObject:dict];
                    }];
                    [info addObjectsFromArray:arr];
                }
            }];
   
        }
    }];
    return info;
}

@end
