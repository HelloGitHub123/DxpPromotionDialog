#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DXPPromotionLifecycleDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 对应 Android DxpPromotion 门面
@interface DXPPromotion : NSObject

+ (void)initSDK;
+ (void)setPromotionLifecycleListener:(nullable id<DXPPromotionLifecycleDelegate>)listener;
+ (void)refreshDataOnViewController:(UIViewController *)viewController
                         completion:(nullable DXPPromotionRefreshBlock)completion;
+ (void)showPromotionOnViewController:(UIViewController *)viewController;

/// Manager 层：轮询查询（未在 Android 门面暴露，iOS 同样提供）
+ (void)queryDxpPromotionDialogPoll;
+ (void)queryDxpPromotionDialogOnce;
+ (void)notifyViewControllerDidAppear:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
