//
//  MyExam.h
//  QR code
//
//  Created by Terry  on 14-1-22.
//  Copyright (c) 2014年 斌. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MyExam : NSManagedObject

@property (nonatomic, retain) NSString * answer_sheet_id;
@property (nonatomic, retain) NSString * caculated_rate;
@property (nonatomic, retain) NSString * caculated_score;
@property (nonatomic, retain) NSString * exam_id;
@property (nonatomic) BOOL passed;
@property (nonatomic, retain) NSString * rate_score;
@property (nonatomic, retain) NSString * score;
@property (nonatomic, retain) NSString * submitted_at;
@property (nonatomic) BOOL syncFlag;
@property (nonatomic, retain) NSString * total_score;
@property (nonatomic, retain) NSString * user_id;

@end
