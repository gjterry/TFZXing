//
//  NSString+Addition.h
//  nexiumtb2013
//
//  Created by Jiminy on 13-6-19.
//  Copyright (c) 2013年 Edoctor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Addition)

+ (BOOL)IsNilOrEmpty:(NSString *)str;

/**
 * 计算字符串使用指定宽度和指定字体的情况下所使用的高度
 * @return CGFloat 字符串的高度
 */
- (CGFloat)heightForWidth:(CGFloat)width
                     font:(UIFont *)font;

@end
