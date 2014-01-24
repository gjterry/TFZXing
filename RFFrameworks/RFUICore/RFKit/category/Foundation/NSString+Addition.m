//
//  NSString+Addition.m
//  nexiumtb2013
//
//  Created by Jiminy on 13-6-19.
//  Copyright (c) 2013年 Edoctor. All rights reserved.
//

#import "NSString+Addition.h"

@implementation NSString (Addition)

/**
 * 验证字符串是否为空
 * @param str   待验证字符串
 * @return BOOL 字符串是否为空,为空或者str不是字符串类型返回true/YES，不为空返回false/No
 */
+ (BOOL)IsNilOrEmpty:(NSString *)str {
    if (![str isKindOfClass:[NSString class]]) {
        return YES;
    }
    
	if (str == nil) {
		return YES;
	}
	
	NSMutableString *string = [[NSMutableString alloc] init];
	[string setString:str];
	CFStringTrimWhitespace((__bridge CFMutableStringRef)string);
	if([string length] == 0)
	{
		return YES;
	}
	return NO;
}

/**
 * 计算字符串使用指定宽度和指定字体的情况下所使用的高度
 * @return CGFloat 字符串的高度
 */
- (CGFloat)heightForWidth:(CGFloat)width
                     font:(UIFont *)font {
    CGSize textSize = {0, 0};
    if (![NSString IsNilOrEmpty:self])
        textSize = [self sizeWithFont:font
                    constrainedToSize:CGSizeMake(width, 99999)
                        lineBreakMode:UILineBreakModeWordWrap];
    return textSize.height;
}

@end
