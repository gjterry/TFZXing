//
//  MyExam+Common.h
//  TSA
//
//  Created by Terry  on 13-7-2.
//  Copyright (c) 2013年 ED. All rights reserved.
//

#import "MyExam.h"
static NSString *const CDENMyExam = @"MyExam";

@interface MyExam (Common)
+ (MyExam *)entityWithuid:(NSString *)uid
             submitted_at:(NSString *)submitted_at
          creatIfNotExist:(BOOL)creatIfNotExist;
//返回我的所有考过的examID
+ (NSArray *)myExamLogID;

+ (MyExam *)latestExamLogOfExamID:(NSString *)exam_id;

+ (NSInteger)countOfExamID:(NSString *)exam_ID;



- (void)updateWithDictionary:(NSDictionary *)dictionary;


/*获取最新的一条有效的考试记录*/
+ (MyExam *)latestValidExamLogWithExamID:(NSString *)examID
                             limitCount:(NSInteger)limitCount;

/*获取对指定考试的记录*/
+ (NSArray *)fetchExamLogWithExamID:(NSString *)examID;

/*获取对指定考试的有效记录*/
+ (NSArray *)fetchValidExamLogWithExamID:(NSString *)examID
                              limitCount:(NSInteger)limitCount;

/*删除表数据*/
+ (void)deleteMyExam;
@end
