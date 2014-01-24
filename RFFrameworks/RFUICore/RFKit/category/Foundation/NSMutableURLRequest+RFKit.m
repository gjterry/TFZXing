//
//  NSMutableURLRequest+RFKit.m
//  iPromote
//
//  Created by Terry  on 13-3-14.
//  Copyright (c) 2013年 edoctor. All rights reserved.
//

#import "NSMutableURLRequest+RFKit.h"

@implementation NSMutableURLRequest (RFKit)

+ (NSMutableURLRequest *)bodyWithPara:(NSDictionary *)para
                               Method:(NSString *)method
                                  URL:(NSURL *)URL   {
    NSData *body = nil;
    NSMutableString *params = nil;
    if(nil != para){
        params = [[NSMutableString alloc] init];
        for(id key in [para allKeys]){
            if (key) {
                NSString *encodedkey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                CFStringRef value = (__bridge CFStringRef)[[para objectForKey:key] copy];
                CFStringRef encodedValue = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, value,NULL,(CFStringRef)@";/?:@&=+$", kCFStringEncodingUTF8);
                [params appendFormat:@"%@=%@&", encodedkey, encodedValue];
            }
        }
        if ([params length] >1) {
        [params deleteCharactersInRange:NSMakeRange([params length] - 1, 1)];
        }

    }
    if([method isEqualToString:@"POST"]){
        body = [params dataUsingEncoding:NSUTF8StringEncoding];
    }else{
        if(nil != para){
            NSString *urlWithParams = [[URL absoluteString] stringByAppendingFormat:@"?%@", params];
            URL = [NSURL URLWithString:urlWithParams];
        }
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:method];
    [request setHTTPBody:body];
    return request;
}

@end
