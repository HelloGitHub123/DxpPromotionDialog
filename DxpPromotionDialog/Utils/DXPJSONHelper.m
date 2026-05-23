#import "DXPJSONHelper.h"

@implementation DXPJSONHelper

+ (NSString *)stringFromObject:(id)obj {
    if (!obj) return nil;
    if ([obj isKindOfClass:[NSString class]]) return obj;
    if ([obj isKindOfClass:[NSNumber class]]) return [(NSNumber *)obj stringValue];
    return [obj description];
}

+ (BOOL)isEmptyString:(NSString *)str {
    return str == nil || str.length == 0;
}

+ (BOOL)string:(NSString *)a equals:(NSString *)b {
    if (a == nil && b == nil) return YES;
    if (a == nil || b == nil) return NO;
    return [a isEqualToString:b];
}

+ (NSString *)stringValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value isKindOfClass:[NSNumber class]]) return [(NSNumber *)value stringValue];
    return nil;
}

+ (NSNumber *)numberValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) return @([(NSString *)value doubleValue]);
    return nil;
}

+ (NSArray *)arrayValue:(id)value {
    return [value isKindOfClass:[NSArray class]] ? value : nil;
}

+ (NSDictionary *)dictionaryValue:(id)value {
    return [value isKindOfClass:[NSDictionary class]] ? value : nil;
}

+ (NSInteger)integerValue:(id)value defaultValue:(NSInteger)defaultValue {
    NSNumber *n = [self numberValue:value];
    return n ? n.integerValue : defaultValue;
}

+ (BOOL)boolValue:(id)value defaultValue:(BOOL)defaultValue {
    if ([value isKindOfClass:[NSNumber class]]) return [(NSNumber *)value boolValue];
    if ([value isKindOfClass:[NSString class]]) return [(NSString *)value boolValue];
    return defaultValue;
}

@end
