//
//  ExamResult.h
//  QR code
//
//  Created by Terry  on 14-1-22.
//  Copyright (c) 2014年 斌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ExamResult : NSManagedObject

@property (nonatomic, retain) NSString * answerPairs;
@property (nonatomic, retain) NSString * answerSheet_id;
@property (nonatomic, retain) NSString * exam_id;
@property (nonatomic) NSTimeInterval insertTime;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) BOOL sync;

@end
