#import <Foundation/Foundation.h>

@class DXPPopUp;

NS_ASSUME_NONNULL_BEGIN

@protocol DXPPromotionLifecycleDelegate <NSObject>
@optional
- (void)promotionDidShow:(DXPPopUp *)popUp;
/// 媒体区域等内容点击
- (void)promotionDidClick:(DXPPopUp *)popUp;
- (void)promotionDidClose:(DXPPopUp *)popUp;
/// 弹框底部主/副按钮点击（含 popup 配置与 jumpUrl）
- (void)promotionDidButtonClick:(DXPPopUp *)popUp;
- (void)promotionDidPrimaryButtonClick:(DXPPopUp *)popUp;
- (void)promotionDidSecondaryButtonClick:(DXPPopUp *)popUp;
@end

typedef void(^DXPPromotionRefreshBlock)(BOOL success);

NS_ASSUME_NONNULL_END
