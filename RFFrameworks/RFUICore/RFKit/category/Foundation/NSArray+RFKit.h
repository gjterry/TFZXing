/*!
 NSArray extension
 RFKit
 
 Copyright (c) 2012-2013 BB9z
 http://github.com/bb9z/RFKit
 
 The MIT License (MIT)
 http://www.opensource.org/licenses/mit-license.php
 */

#import <Foundation/Foundation.h>

@interface NSArray (RFKit)

- (id)firstObject;

- (NSArray *)subArrayWithCount:(NSInteger)count;
@end

@interface NSMutableArray (RFKit)

- (NSMutableArray *)distinctedwithBlock:(BOOL(^)(id obj1, id obj2))isEqual;

- (void)addObjectsFromDictionary:(NSDictionary *)otherDictionary keys:(NSString *)firstKey, ...NS_REQUIRES_NIL_TERMINATION;
- (void)unionArray:(NSMutableArray *)arr withBlock:(BOOL(^)(NSMutableArray *aimArray, id obj2))distinctCondition;

- (NSMutableArray *)dividedBySize:(NSInteger)size;
@end
