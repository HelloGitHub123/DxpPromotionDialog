#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 封装 DXPToolsLib Loading，pod 不可用时为空实现
@interface DXPToolsLoadingHelper : NSObject

+ (void)showLoading;
+ (void)hideLoading;

@end

NS_ASSUME_NONNULL_END
