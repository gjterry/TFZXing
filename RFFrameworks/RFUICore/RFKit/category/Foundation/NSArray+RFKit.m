
#import "RFKit.h"
#import "NSArray+RFKit.h"

@implementation NSArray (RFKit)

- (id)firstObject {
    return (self!=nil && self.count>0) ? [self objectAtIndex:0] : nil;
}

- (NSArray *)subArrayWithCount:(NSInteger)count {
    if (self.count <= count) {
        return self;
    }
    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:0];
    NSInteger i = 0;
    while (i < count) {
        [tmp addObject:self[i]];
    i ++;
    }
    return [NSArray arrayWithArray:tmp];
}

@end

@implementation NSMutableArray (RFKit)

- (NSMutableArray *)distinctedwithBlock:(BOOL(^)(id obj1, id obj2))isEqual {
    NSMutableArray *array = [NSMutableArray array];
    for (id aItem in self) {
        BOOL existence = [self checkExistenceInArray:array checkItem:aItem withBlock:^BOOL(id obj1, id obj2) {
            return isEqual(obj1,obj2);
        }];
        if (!existence) [array addObject:aItem];
    }
    return array;
}


- (BOOL)checkExistenceInArray:(NSMutableArray *)checkedArray checkItem:(id)checkedItem withBlock:(BOOL(^)(id obj1, id obj2))isEqual {
    for (id aItem in checkedArray)
        return  isEqual(aItem,checkedItem);
    
    return NO;
}

- (void)addObjectsFromDictionary:(NSDictionary *)sourceDictionary keys:(NSString *)firstKey, ... {
    va_list ap;
    va_start(ap, firstKey);
    for (NSString *key = firstKey; key != nil; key = va_arg(ap, id)) {
        id tmp = [sourceDictionary objectForKey:key];
        if (tmp) {
            [self addObject:tmp];
        }
    }
    va_end(ap);
}


//指针比较 以后再详细到元素
- (void)unionArray:(NSMutableArray *)arr withBlock:(BOOL(^)(NSMutableArray *aimArray, id obj2))distinctCondition {
    NSMutableArray *result = [NSMutableArray array];
    for (id object in arr) {
        if(distinctCondition(self,object))
            [result addObject:object];
    }
    [self addObjectsFromArray:result];
}

- (NSMutableArray *)dividedBySize:(NSInteger)size {
        int category_count = [self count];
        int arr_count;
        int mod = category_count % size;
        int left;
        if (category_count >0) {
            if (mod == 0) {
                arr_count = category_count/size;
                left = size;
            }else{
                arr_count = category_count/size + 1;
                left = mod;
            }
            NSMutableArray *arraySet = [NSMutableArray arrayWithObjects:nil];
            for (int i = 0; i<arr_count; i++) {
                NSMutableArray *each = [NSMutableArray arrayWithObjects:nil];
                for (int j = i*size; j<(i+1==arr_count?(left+i*size):(i+1)*size); j++) {
                    [each addObject:[self objectAtIndex:j]];
                }
                [arraySet addObject:each];
                
            }
            return arraySet;
        }
        return nil;
}

@end
