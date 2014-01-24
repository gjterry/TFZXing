//
//  ExamResult+Common.m
//  Roche
//
//  Created by Terry  on 13-8-6.
//  Copyright (c) 2013年 ED. All rights reserved.
//



#import "NSJSONSerialization+RFKit.h"
#import "DataStack.h"
#import "ExamResult+Common.h"

@implementation ExamResult (Common)
+ (ExamResult *)entityWithUid:(NSString *)uid
                answerSheetID:(NSString *)answerSheetID
              creatIfNotExist:(BOOL)creatIfNotExist {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@ && answerSheet_id = %@",uid,answerSheetID];
    
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    if (e) dout_error(@"%@", e);
    
    if (results.count >= 1) {
        return [results firstObject];
    }
    else if (results.count == 0) {
        if (creatIfNotExist) {
            ExamResult *obj = [NSEntityDescription insertNewObjectForEntityForName:UNEKExamResult inManagedObjectContext:[DataStack sharedInstance].context];
            obj.exam_id = uid;
            obj.answerSheet_id = answerSheetID;
            return obj;
        }
    }
    else {
        RFAssert(false, @"存在多个UID相同的Entity");
    }
    return nil;
}

+ (ExamResult *)insertWithUid:(NSString *)uid {
    ExamResult *obj = [NSEntityDescription insertNewObjectForEntityForName:UNEKExamResult inManagedObjectContext:[DataStack sharedInstance].context];
    obj.exam_id = uid;
    return obj;
}

- (NSArray *)answerPairsArray {
    return [NSJSONSerialization JSONObjectWithString:self.answerPairs usingEncoding:NSUTF8StringEncoding allowLossyConversion:YES options:0 error:nil];
}

+ (ExamResult *)latestSyncExamResultOfExamID:(NSString *)exam_id {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@ && sync = YES", exam_id];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"insertTime" ascending:NO]];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results.count > 0?results[0]:nil;
}

+ (ExamResult *)latestUnSyncExamResultOfExamID:(NSString *)exam_id {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@ && sync = NO", exam_id];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"insertTime" ascending:NO]];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results.count > 0?results[0]:nil;
}

+ (ExamResult *)latestExamResultOfExamID:(NSString *)exam_id {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@", exam_id];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"insertTime" ascending:NO]];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results.count > 0?results[0]:nil;
}


/*是否存在没有同步过的考试记录*/
+ (BOOL)isExistUnSyncExamResultOfExamID:(NSString *)exam_id {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@ && sync = NO", exam_id];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"insertTime" ascending:NO]];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results.count > 0;
}

/*根据examID和answer_sheet_id 来查询到相应的ExamResult(答卷)*/
+ (ExamResult *)fetchExamResultWithExamID:(NSString *)examID
                          answer_sheet_id:(NSString *)answer_sheet_id {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@ && answerSheet_id = %@", examID,answer_sheet_id];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"insertTime" ascending:NO]];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results.count > 0?results[0]:nil;
}

+ (NSArray *)notSyncExamResultOfExamID:(NSString *)examID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@ && sync = NO", examID];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"insertTime" ascending:NO]];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results;
}

+ (NSArray *)resultsOfExamID:(NSString *)exam_id {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@", exam_id];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"insertTime" ascending:NO]];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results;
}

+ (NSArray *)unSyncExamResultOfExamID:(NSString *)exam_id {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@ && sync = NO", exam_id];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"insertTime" ascending:YES]];
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:nil];
    return results;
}

+ (NSInteger)countOfExamResult:(NSString *)exam_id {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@", exam_id];
    request.sortDescriptors = @[];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results.count;
}

+ (void)removeNotSyncData {
    
}

+ (void)deleteDataFromTable {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:UNEKExamResult];
    request.sortDescriptors = @[];
    request.predicate = [NSPredicate predicateWithFormat:@"1=1"];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ExamResult *aExamResult = (ExamResult *)obj;
        [aExamResult destroy];
    }];
    [[DataStack sharedInstance]save];
}


@end
