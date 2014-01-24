//
//  NSMutableURLRequest+RFKit.h
//  iPromote
//
//  Created by Terry  on 13-3-14.
//  Copyright (c) 2013年 edoctor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (RFKit)

+ (NSMutableURLRequest *)bodyWithPara:(NSDictionary *)para
                               Method:(NSString *)method
                                  URL:(NSURL *)URL;
@end
