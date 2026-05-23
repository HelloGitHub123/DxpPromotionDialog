#import <UIKit/UIKit.h>
#import "DXPPromotionDialogDelegate.h"

@class DXPPopUp;
@class DXPPromotionInfo;

NS_ASSUME_NONNULL_BEGIN

@interface DXPBasePromotionViewController : UIViewController

@property (nonatomic, weak, nullable) id<DXPPromotionDialogDelegate> dialogDelegate;
@property (nonatomic, copy, nullable) void(^onDismissBlock)(void);

- (DXPPopUp *)buildPopUpWithJumpUrl:(nullable NSString *)jumpUrl transactionSn:(nullable NSString *)transactionSn;
- (DXPPopUp *)buildPopUpWithPromotionInfo:(DXPPromotionInfo *)info jumpUrl:(nullable NSString *)jumpUrl;

@end

NS_ASSUME_NONNULL_END
