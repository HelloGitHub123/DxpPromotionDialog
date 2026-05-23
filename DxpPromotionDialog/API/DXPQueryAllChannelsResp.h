#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXPQueryAllChannelsResp : NSObject

@property (nonatomic, copy, nullable) NSString *resultCode;
@property (nonatomic, copy, nullable) NSString *resultMsg;

+ (instancetype)modelWithDictionary:(nullable NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
