//
//  User+Common.h
//  RocheLearnCenter
//
//  Created by Terry  on 13-7-16.
//  Copyright (c) 2013年 ED. All rights reserved.
//

#import "User.h"

@interface User (Common)
+ (User *)userWithID:(NSString *)user_id createIfNotExist:(BOOL)creatIfNotExist;


+ (User *)currentUserInstance;

+ (void)deleteUsers;

+ (BOOL)userChangedWithID:(NSString *)userID;

- (NSArray *)fetchMyDepartmentInfo:(NSArray *)source;

@end
