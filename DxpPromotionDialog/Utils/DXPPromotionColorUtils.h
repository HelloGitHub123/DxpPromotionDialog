#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXPPromotionColorUtils : NSObject

+ (UIColor *)parseColor:(nullable NSString *)colorString;
/// percent 为 0–100 的透明度，内部除以 100 作为 alpha
+ (UIColor *)parseColor:(nullable NSString *)colorString opacityPercent:(NSInteger)percent;
+ (UIColor *)colorWithHexString:(NSString *)hex alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
