//
//  User.h
//  QR code
//
//  Created by Terry  on 14-1-22.
//  Copyright (c) 2014年 斌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * avatar_url;
@property (nonatomic, retain) NSString * current_team_id;
@property (nonatomic, retain) NSString * device_id;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * team_id;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * user_role;

@end
