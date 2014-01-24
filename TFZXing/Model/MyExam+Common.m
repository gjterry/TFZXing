//
//  MyExam+Common.m
//  TSA
//
//  Created by Terry  on 13-7-2.
//  Copyright (c) 2013年 ED. All rights reserved.
//
#import "DataStack.h"
#import "MyExam+Common.h"

@implementation MyExam (Common)
+ (MyExam *)entityWithuid:(NSString *)uid
             submitted_at:(NSString *)submitted_at
          creatIfNotExist:(BOOL)creatIfNotExist {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDENMyExam];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@ && submitted_at= %@", uid,submitted_at];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    if (e) dout_error(@"%@", e);
    
    if (results.count == 1) {
        return [results firstObject];
    }
    else if (results.count == 0) {
        if (creatIfNotExist) {
            MyExam *obj = [NSEntityDescription insertNewObjectForEntityForName:CDENMyExam inManagedObjectContext:
                           [DataStack sharedInstance].context];
            obj.exam_id = uid;
            obj.submitted_at = submitted_at;
            return obj;
        }
    }
    else {
        RFAssert(false, @"存在多个UID相同的Entity");
    }
    return nil;
}

+ (NSArray *)myExamLogID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDENMyExam];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:0];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MyExam *exam = (MyExam *)obj;
        [tmp addObject:exam.exam_id];
    }];
    return [NSArray arrayWithArray:tmp];
}

+ (MyExam *)latestExamLogOfExamID:(NSString *)exam_id {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDENMyExam];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@", exam_id];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"submitted_at" ascending:NO]];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return results.count > 0?results[0]:nil;
}

+ (NSInteger)countOfExamID:(NSString *)exam_ID {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDENMyExam];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@", exam_ID];
    NSError *e = nil;
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:&e];
    return [results count];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    self.user_id = strOrEmpty(dictionary[@"user_id"]);
    self.score =  [NSString stringWithFormat:@"%.2f",[strOrEmpty(dictionary[@"score"])floatValue]];
    self.answer_sheet_id = strOrEmpty(dictionary[@"answer_sheet_id"]);
    self.total_score = [NSString stringWithFormat:@"%.2f",[strOrEmpty(dictionary[@"total_score"])floatValue]];
    self.caculated_score = [NSString stringWithFormat:@"%.2f",[strOrEmpty(dictionary[@"caculated_score"])floatValue]];
    self.caculated_rate = [NSString stringWithFormat:@"%.2f",[strOrEmpty(dictionary[@"caculated_rate"])floatValue]];

    if (dictionary[@"passed"]) {
        self.passed = [dictionary[@"passed"] boolValue];        
    }else
        self.passed = NO;

    self.syncFlag = YES;        
}

NSString* strOrEmpty(NSString* str) {
	return (str==nil||[str isKindOfClass:[NSNull class]]?@"":str);
}

/*获取最新的一条有效的考试记录*/
+ (MyExam *)latestValidExamLogWithExamID:(NSString *)examID
                              limitCount:(NSInteger)limitCount {
  __block  MyExam *passedExam = nil;
   NSArray *array = [MyExam fetchValidExamLogWithExamID:examID limitCount:limitCount];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MyExam *myExam = (MyExam *)obj;
        if (myExam.passed){
            passedExam = myExam;
            *stop = YES;
        }
    }];
    if (passedExam) return passedExam;
    return array.count > 0?[array lastObject]:nil;
}


/*获取对指定考试的有效记录*/
+ (NSArray *)fetchValidExamLogWithExamID:(NSString *)examID
                              limitCount:(NSInteger)limitCount {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDENMyExam];
    request.predicate = [NSPredicate predicateWithFormat:@"exam_id = %@", examID];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"submitted_at" ascending:YES]];
    request.fetchLimit = limitCount;
    NSError *e = nil;
    NSArray *results = [NSArray arrayWithArray:[[DataStack sharedInstance].context executeFetchRequest:request error:&e]];
    
//    NSLog(@"examID:%@    logCount:%d",examID,results.count);

    return results;
}

+ (void)deleteMyExam {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:CDENMyExam];
    NSArray *results = [[DataStack sharedInstance].context executeFetchRequest:request error:nil];
    for (MyExam *aExam in results) {
        [[DataStack sharedInstance].context deleteObject:aExam];
    }
}
@end
