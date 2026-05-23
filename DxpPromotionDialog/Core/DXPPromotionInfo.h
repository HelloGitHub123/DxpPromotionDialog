#import <Foundation/Foundation.h>

@class DXPMktCreativeInfo;

NS_ASSUME_NONNULL_BEGIN

@interface DXPPromotionInfo : NSObject

@property (nonatomic, copy, nullable) NSString *batchId;
@property (nonatomic, copy, nullable) NSString *campaignCode;
@property (nonatomic, strong, nullable) DXPMktCreativeInfo *mktCreativeInfo;
@property (nonatomic, copy, nullable) NSString *popupPageURL;
@property (nonatomic, copy, nullable) NSString *transactionSn;

@end

NS_ASSUME_NONNULL_END
