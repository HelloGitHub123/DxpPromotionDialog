#import "DXPBasePromotionViewController.h"

@class DXPPromotionInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 * 运营弹窗样式营销对话框。
 *
 * 根据服务端下发的 DXPPopupModel 配置，纯代码构建 UI，支持：
 * - 背景图/纯色、遮罩、居中或底部展示
 * - 媒体图、主/副标题、主/次按钮
 * - 关闭按钮、点击遮罩关闭、倒计时自动关闭
 *
 * 由 DXPPromotionManager 在 popup 类型活动时创建并 present。
 */
@interface DXPPopupPromotionViewController : DXPBasePromotionViewController

/// 使用营销数据初始化弹窗
- (instancetype)initWithPromotionInfo:(DXPPromotionInfo *)info;

@end

NS_ASSUME_NONNULL_END
