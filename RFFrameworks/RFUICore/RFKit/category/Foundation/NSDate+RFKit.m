
#define kDEFAULT_DATE_TIME_FORMAT @"yyyy-MM-dd HH:mm"
#define kDEFAULT_SECOND_DATE_TIME_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define kDEFAULT_T_DATE_TIME_FORMAT @"yyyy-MM-dd'T'HH:mm:ss+00:00"
#import "NSDate+RFKit.h"

@implementation NSDate (RFKit)

- (BOOL)isSameDayWithDate:(NSDate *)date {
    NSDateComponents *target = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    NSDateComponents *source = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    return [target isEqual:source];
}

- (void)show {
	NSDateFormatter* formater = [[NSDateFormatter alloc] init];
	[formater setDateFormat:@"yyyy-MM-dd HH:mm"];
	[formater setTimeZone:[NSTimeZone localTimeZone]];
	NSString* timeDesp = [formater stringFromDate:self];
	NSLog(@"date:%@", timeDesp);
}

+ (NSDate *)convertFromDate:(NSDate *)date {
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval_start = [zone secondsFromGMTForDate:date];
    NSDate *convertDate = [date dateByAddingTimeInterval:interval_start];
    return convertDate;
}

+ (NSString *)nowDate {
    NSDate* now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:unitFlags fromDate:now];
    int hour = [comps hour];
    int min = [comps minute];
    int sec = [comps second];
    int year = [comps year];
    int month = [comps month];
    int day = [comps day];
    
    NSString *time =  [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min,sec];
    NSString *date = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];
    NSString *date_time = [NSString stringWithFormat:@"%@ %@",date ,time];
    return date_time;
}

+(NSDate *)NSStringDateToNSDate:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:kDEFAULT_DATE_TIME_FORMAT];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+(NSDate *)NSStringDateToNSDateWithSecond:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:kDEFAULT_SECOND_DATE_TIME_FORMAT];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+(NSDate *)NSStringDateToNSDateWithT:(NSString *)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:kDEFAULT_T_DATE_TIME_FORMAT];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+ (NSDate *)localNowDate {
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}


- (NSString *)showSelf {
	NSDateFormatter* formater = [[NSDateFormatter alloc] init];
	[formater setDateFormat:@"yyyy-MM-dd HH:mm"];
	[formater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString* timeDesp = [formater stringFromDate:self];
	return timeDesp;
}

- (NSString *)showSelfWithSecond {
	NSDateFormatter* formater = [[NSDateFormatter alloc] init];
	[formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[formater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString* timeDesp = [formater stringFromDate:self];
	return timeDesp;
}

- (NSString *)showSelfWithoutTime {
	NSDateFormatter* formater = [[NSDateFormatter alloc] init];
	[formater setDateFormat:@"yyyy-MM-dd"];
	[formater setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString* timeDesp = [formater stringFromDate:self];
	return timeDesp;
}

- (NSArray *)componentsOfDate:(NSDate *)date {
    NSMutableArray *components = [NSMutableArray arrayWithCapacity:0];
    NSString  *dateStr = [date showSelf];
    NSArray * array = [[dateStr componentsSeparatedByString:@" "][0]componentsSeparatedByString:@"-"];
    NSString *yearString = array[0];
    NSString *monthString = [NSString stringWithFormat:@"%d",[array[1]integerValue]];
    NSString *weekString  = [self trans:[self dayOfWeek:date]];
    NSString *dayString =  array[2];
    [components addObject:yearString];
    [components addObject:monthString];
    [components addObject:weekString];
    [components addObject:dayString];
    return components;
}

- (NSString *)daySinceNowReferenceDate:(NSString *)dateString {
    NSDate *compareDate = [NSDate NSStringDateToNSDateWithSecond:dateString];
    NSString *compareDateString = [compareDate description];
    NSString *hourString = [compareDateString componentsSeparatedByString:@" "][1];
    NSString *hourStingNoSeconds = [hourString substringToIndex:[hourString length]-3];
    NSString *dateFormatString = @"";
    
    NSTimeInterval interval = [[NSDate localNowDate]timeIntervalSinceDate:compareDate];
    
    NSInteger day = interval/24/3600;
    if ( day == 0 )
        dateFormatString = [NSString stringWithFormat:@"今天 %@",hourStingNoSeconds];
    else if ( day == 1 )
        dateFormatString = [NSString stringWithFormat:@"昨天 %@",hourStingNoSeconds];
    else if ( day == 2 )
        dateFormatString = [NSString stringWithFormat:@"前天 %@",hourStingNoSeconds];
    else
        dateFormatString = [NSString stringWithFormat:@"%@ %@",[compareDateString componentsSeparatedByString:@" "][0],hourStingNoSeconds];
    
    return dateFormatString;
}

- (NSString *)weekOfDate:(NSDate *)date {
    return   [self trans:[self dayOfWeek:date]];

}

- (NSString *)trans:(NSString *)d {
    if ([d isEqualToString:@"Mon"]) {
        return @"周一";
    }
    if ([d isEqualToString:@"Tue"]) {
        return @"周二";
    }
    if ([d isEqualToString:@"Wed"]) {
        return @"周三";
    }
    if ([d isEqualToString:@"Thu"]) {
        return @"周四";
    }
    if ([d isEqualToString:@"Fri"]) {
        return @"周五";
    }
    if ([d isEqualToString:@"Sat"]) {
        return @"周六";
    }
    if ([d isEqualToString:@"Sun"]) {
        return @"周日";
    }else
        return @"";
}

- (NSString *)weekOfNum:(int)num {
    return Nil;
}

- (NSString *)monthOfNum:(int)num {
    switch (num) {
        case 1:
            return @"January";
            break;
        case 2:
            return @"February";
            break;
        case 3:
            return @"March";
            break;
        case 4:
            return @"April";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"June";
            break;
        case 7:
            return @"July";
            break;
        case 8:
            return @"August";
            break;
        case 9:
            return @"September";
            break;
        case 10:
            return @"October";
            break;
        case 11:
            return @"November";
            break;
        case 12:
            return @"December";
            break;
    }
    return @"";
}

-(NSString*)dayOfWeek:(NSDate *)d{
    NSDateFormatter *fmtter =[[NSDateFormatter alloc] init] ;
    [fmtter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [fmtter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [fmtter setDateFormat:@"EEE"];
    return [fmtter stringFromDate:d];
}

-(DayOfWeekType)dayOfWeekType:(NSDate*)date{
    NSString* dayString = [self dayOfWeek:date];
    if (nil == dayString) {
        return DayOfWeekUnknown;
    }
    
    if ([dayString hasPrefix:@"Mon"]) {
        return DayOfWeekMon;
    }
    if ([dayString hasPrefix:@"Tue"]) {
        return DayOfWeekTue;
    }
    if ([dayString hasPrefix:@"Wed"]) {
        return DayOfWeekWed;
    }
    if ([dayString hasPrefix:@"Thu"]) {
        return DayOfWeekThu;
    }
    if ([dayString hasPrefix:@"Fri"]) {
        return DayOfWeekFri;
    }
    if ([dayString hasPrefix:@"Sat"]) {
        return DayOfWeekSat;
    }
    if ([dayString hasPrefix:@"Sun"]) {
        return DayOfWeekSun;
    }
    return DayOfWeekUnknown;
}

@end
