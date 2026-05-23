#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXPChannelReq : NSObject

@property (nonatomic, copy, nullable) NSString *transactionSn;
@property (nonatomic, copy, nullable) NSString *status;

- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END
