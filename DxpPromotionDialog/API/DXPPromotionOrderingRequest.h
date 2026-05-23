#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 对应 Android PromotionOrderingRequest，当前 Manager 未调用订购接口
@interface DXPPromotionOrderingRequest : NSObject

@property (nonatomic, copy, nullable) NSString *channel;
@property (nonatomic, copy, nullable) NSString *adSlot;
@property (nonatomic, strong, nullable) NSNumber *contactId;
@property (nonatomic, copy, nullable) NSString *campaignCode;
@property (nonatomic, strong, nullable) NSNumber *subsId;
@property (nonatomic, copy, nullable) NSString *serviceNumber;
@property (nonatomic, copy, nullable) NSString *transactionSn;

@end

NS_ASSUME_NONNULL_END
