#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 按图片宽高比计算展示尺寸（对齐 Android adjustViewBounds + wrap_content）
@interface DXPPromotionImageLayoutHelper : NSObject

+ (CGSize)displaySizeForImage:(UIImage *)image
                containerSize:(CGSize)containerSize
         horizontalMarginTotal:(CGFloat)horizontalMarginTotal
               maxHeightRatio:(CGFloat)maxHeightRatio;

+ (void)updateImageView:(UIImageView *)imageView
              withImage:(UIImage *)image
          containerView:(UIView *)containerView
    horizontalMarginTotal:(CGFloat)horizontalMarginTotal
         maxHeightRatio:(CGFloat)maxHeightRatio;

@end

NS_ASSUME_NONNULL_END
