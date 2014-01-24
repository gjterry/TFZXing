
#import "RFKit.h"
#import "NSDictionary+RFKit.h"

@implementation NSDictionary (RFKit)

- (id)objectForKey:(id)aKey defaultMarker:(id)anObject {
	return [self get:[self objectForKey:aKey] defaults:anObject];
}

- (BOOL)boolForKey:(NSString *)keyName {
    return [[self objectForKey:keyName] boolValue];
}
- (float)floatForKey:(NSString *)keyName {
    return [[self objectForKey:keyName] floatValue];
}
- (NSInteger)integerForKey:(NSString *)keyName {
    return [[self objectForKey:keyName] integerValue];
}
- (double)doubleForKey:(NSString *)keyName {
    return [[self objectForKey:keyName] doubleValue];
}

+ (NSDictionary *)dictionaryFormatWithDictionary:(NSDictionary *)dictionary {
    NSArray *allKeys = [dictionary allKeys];
    NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:0];
    [allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = (NSString *)obj;
        id value = dictionary[key];
        if (!value || [value isKindOfClass:[NSNull class]])
            [temp setObject:@"" forKey:key];
        else
            [temp setObject:value forKey:key];
    }];
    NSDictionary *formartDictionary = [NSDictionary dictionaryWithDictionary:temp];
    return formartDictionary;
}

+ (id)dataRemoveNull:(id)dataOrg {
    id resultData = nil;
    if ([dataOrg isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] initWithDictionary:dataOrg];
        for (int i = 0; i < [dictTemp allKeys].count; i++) {
            NSString *key = [[dictTemp allKeys] objectAtIndex:i];
            id value = dictTemp[key];
            if ([value isKindOfClass:[NSNull class]]) {
                [dictTemp setObject:@"" forKey:key];
            }
            if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                [dictTemp setObject:[NSDictionary dataRemoveNull:value] forKey:key];
            }
        }
        resultData = dictTemp;
    }
    
    if ([dataOrg isKindOfClass:[NSArray class]]) {
        NSMutableArray *arrayTemp = [[NSMutableArray alloc] initWithArray:dataOrg];
        for (int i = 0; i < arrayTemp.count; i++) {
            id value = arrayTemp[i];
            if ([value isKindOfClass:[NSNull class]]) {
                [arrayTemp replaceObjectAtIndex:i withObject:@""];
            }
            if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                [arrayTemp replaceObjectAtIndex:i withObject:[NSDictionary dataRemoveNull:value]];
            }
        }
        resultData = arrayTemp;
    }
    
    if ([dataOrg isKindOfClass:[NSNull class]]) {
        resultData = dataOrg = @"";
    }
    
    return resultData;
}

@end

@implementation NSMutableDictionary (RFKit)

- (NSUInteger)copyObjectsFromDictionary:(NSDictionary *)sourceDictionary withKeys:(NSString *)firstKey, ... {
    NSUInteger keyCopedCount = 0;
    va_list ap;
    va_start(ap, firstKey);
    for (NSString *key = firstKey; key != nil; key = va_arg(ap, id)) {
        id tmp = [sourceDictionary objectForKey:key];
        if (tmp) {
            [self setObject:tmp forKey:key];
            keyCopedCount++;
        }
    }
    va_end(ap);
    return keyCopedCount;
}

- (void)setBool:(BOOL)value forKey:(NSString *)keyName {
    [self setObject:[NSNumber numberWithBool:value] forKey:keyName];
}
- (void)setFloat:(float)value forKey:(NSString *)keyName {
    [self setObject:[NSNumber numberWithFloat:value] forKey:keyName];
}
- (void)setInteger:(NSInteger)value forKey:(NSString *)keyName {
    [self setObject:[NSNumber numberWithInteger:value] forKey:keyName];
}
- (void)setDouble:(double)value forKey:(NSString *)keyName {
    [self setObject:[NSNumber numberWithDouble:value] forKey:keyName];
}

@end
