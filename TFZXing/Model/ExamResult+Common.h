//
//  ExamResult+Common.h
//  Roche
//
//  Created by Terry  on 13-8-6.
//  Copyright (c) 2013年 ED. All rights reserved.
//

#import "ExamResult.h"
static NSString *const UNEKExamResult = @"ExamResult";
@interface ExamResult (Common)

+ (ExamResult *)entityWithUid:(NSString *)uid
                    answerSheetID:(NSString *)answerSheetID
              creatIfNotExist:(BOOL)creatIfNotExist;
+ (ExamResult *)insertWithUid:(NSString *)uid;

- (NSArray *)answerPairsArray;


+ (ExamResult *)latestSyncExamResultOfExamID:(NSString *)exam_id;
+ (ExamResult *)latestExamResultOfExamID:(NSString *)exam_id;

+ (ExamResult *)latestUnSyncExamResultOfExamID:(NSString *)exam_id;


/*是否存在没有同步过的考试记录*/
+ (BOOL)isExistUnSyncExamResultOfExamID:(NSString *)exam_id;

/*根据examID和answer_sheet_id 来查询到相应的ExamResult(答卷)*/
+ (ExamResult *)fetchExamResultWithExamID:(NSString *)examID
                          answer_sheet_id:(NSString *)answer_sheet_id;

/*没有同步的答卷*/
+ (NSArray *)notSyncExamResultOfExamID:(NSString *)examID;

+ (NSArray *)unSyncExamResultOfExamID:(NSString *)exam_id;
+ (NSArray *)resultsOfExamID:(NSString *)exam_id;

+ (NSInteger)countOfExamResult:(NSString *)exam_id;

+ (void)removeNotSyncData;
+ (void)deleteDataFromTable;
@end
