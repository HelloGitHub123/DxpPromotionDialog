#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DXPPromotionDataListener <NSObject>
- (void)promotionDataDidComplete;
- (void)promotionDataDidFail;
@end

NS_ASSUME_NONNULL_END
