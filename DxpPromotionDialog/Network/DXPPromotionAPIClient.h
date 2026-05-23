#import <Foundation/Foundation.h>

@class DXPQueryPromotionsResp;
@class DXPQueryAllChannelsResp;

NS_ASSUME_NONNULL_BEGIN

typedef void(^DXPPromotionAPISuccessBlock)(id _Nullable response);
typedef void(^DXPPromotionAPIFailureBlock)(NSString * _Nullable resultCode, NSString * _Nullable resultMsg);

/// 营销接口客户端，底层使用 DXPNetWorkingManagerLib
@interface DXPPromotionAPIClient : NSObject

+ (instancetype)sharedClient;

/// GET promotions
- (void)fetchPromotionsWithSubsId:(nullable NSNumber *)subsId
                          channel:(NSString *)channel
                           adSlot:(NSString *)adSlot
                    serviceNumber:(nullable NSString *)serviceNumber
                          success:(void(^)(DXPQueryPromotionsResp *response))success
                          failure:(DXPPromotionAPIFailureBlock)failure;

/// POST webhook status
- (void)reportStatusWithTransactionSn:(nullable NSString *)transactionSn
                               status:(NSString *)status
                              success:(void(^)(DXPQueryAllChannelsResp *response))success
                              failure:(DXPPromotionAPIFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
