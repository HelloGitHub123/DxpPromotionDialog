#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXPJSONHelper : NSObject

+ (nullable NSString *)stringFromObject:(id)obj;
+ (BOOL)isEmptyString:(nullable NSString *)str;
+ (BOOL)string:(nullable NSString *)a equals:(nullable NSString *)b;
+ (nullable NSString *)stringValue:(id)value;
+ (nullable NSNumber *)numberValue:(id)value;
+ (nullable NSArray *)arrayValue:(id)value;
+ (nullable NSDictionary *)dictionaryValue:(id)value;
+ (NSInteger)integerValue:(id)value defaultValue:(NSInteger)defaultValue;
+ (BOOL)boolValue:(id)value defaultValue:(BOOL)defaultValue;

@end

NS_ASSUME_NONNULL_END
