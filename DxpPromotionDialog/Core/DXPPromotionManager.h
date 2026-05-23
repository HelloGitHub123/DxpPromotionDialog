#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DXPPromotionLifecycleDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface DXPPromotionManager : NSObject

@property (nonatomic, weak, nullable) id<DXPPromotionLifecycleDelegate> lifecycleDelegate;
@property (nonatomic, copy, nullable) DXPPromotionRefreshBlock refreshBlock;

+ (instancetype)sharedManager;

- (void)initSDK;
- (void)setPromotionLifecycleListener:(nullable id<DXPPromotionLifecycleDelegate>)listener;

- (void)queryDxpPromotionDialogPoll;
- (void)queryDxpPromotionDialogOnce;
- (void)queryDxpPromotionDialogOnceOnViewController:(UIViewController *)viewController;

- (void)refreshDataOnViewController:(UIViewController *)viewController completion:(nullable DXPPromotionRefreshBlock)completion;
- (void)showPromotionOnViewController:(UIViewController *)viewController;

/// 宿主在 viewDidAppear 中调用，等价 Android onActivityResumed
+ (void)notifyViewControllerDidAppear:(UIViewController *)viewController;

+ (nullable UIViewController *)topViewController;

@end

NS_ASSUME_NONNULL_END
