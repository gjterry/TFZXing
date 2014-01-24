/*!
    NSDate extension
    RFKit

    Copyright (c) 2012-2013 BB9z
    https://github.com/bb9z/RFKit

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php
 */
typedef enum {
    DayOfWeekUnknown = 0,
    DayOfWeekMon,
    DayOfWeekTue,
    DayOfWeekWed,
    DayOfWeekThu,
    DayOfWeekFri,
    DayOfWeekSat,
    DayOfWeekSun
}DayOfWeekType;
#import <Foundation/Foundation.h>

@interface NSDate (RFKit)

- (BOOL)isSameDayWithDate:(NSDate *)date;

- (void)show;


+ (NSDate *)convertFromDate:(NSDate *)date;
+ (NSString *)nowDate;
+(NSDate *)NSStringDateToNSDate:(NSString *)string;
+(NSDate *)NSStringDateToNSDateWithT:(NSString *)string;
+(NSDate *)NSStringDateToNSDateWithSecond:(NSString *)string;

+ (NSDate *)localNowDate;
- (NSString *)showSelf;
- (NSString *)showSelfWithoutTime;
- (NSString *)showSelfWithSecond;

- (NSString *)daySinceNowReferenceDate:(NSString *)dateString;

//index 0 年  1 月 2 周 3 日
- (NSArray *)componentsOfDate:(NSDate *)date;
- (NSString *)monthOfNum:(int)num;
- (NSString *)weekOfNum:(int)num;

- (NSString *)weekOfDate:(NSDate *)date;
@end
