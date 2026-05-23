#import "DXPPromotion.h"
#import "DXPPromotionManager.h"

@implementation DXPPromotion

+ (void)initSDK {
    [[DXPPromotionManager sharedManager] initSDK];
}

+ (void)setPromotionLifecycleListener:(id<DXPPromotionLifecycleDelegate>)listener {
    [[DXPPromotionManager sharedManager] setPromotionLifecycleListener:listener];
}

+ (void)refreshDataOnViewController:(UIViewController *)viewController completion:(DXPPromotionRefreshBlock)completion {
    [[DXPPromotionManager sharedManager] refreshDataOnViewController:viewController completion:completion];
}

+ (void)showPromotionOnViewController:(UIViewController *)viewController {
    [[DXPPromotionManager sharedManager] showPromotionOnViewController:viewController];
}

+ (void)queryDxpPromotionDialogPoll {
    [[DXPPromotionManager sharedManager] queryDxpPromotionDialogPoll];
}

+ (void)queryDxpPromotionDialogOnce {
    [[DXPPromotionManager sharedManager] queryDxpPromotionDialogOnce];
}

+ (void)notifyViewControllerDidAppear:(UIViewController *)viewController {
    [DXPPromotionManager notifyViewControllerDidAppear:viewController];
}

@end
