#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Demo 占位，对应 Android DxpSdkConfig.promotionDialogConfig
@interface DXPDemoPromotionDialogConfig : NSObject
@property (nonatomic, copy, nullable) NSArray<NSString *> *excludePageName;
@end

/// Demo 占位，对应 Android DxpSdkConfig
@interface DXPSDKConfig : NSObject
@property (nonatomic, strong, nullable) DXPDemoPromotionDialogConfig *promotionDialogConfig;
@end

NS_ASSUME_NONNULL_END
