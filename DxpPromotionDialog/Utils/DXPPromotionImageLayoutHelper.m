#import "DXPPromotionImageLayoutHelper.h"
#import <Masonry/Masonry.h>

@implementation DXPPromotionImageLayoutHelper

+ (CGSize)displaySizeForImage:(UIImage *)image
                containerSize:(CGSize)containerSize
         horizontalMarginTotal:(CGFloat)horizontalMarginTotal
               maxHeightRatio:(CGFloat)maxHeightRatio {
    if (!image || image.size.width <= 0 || image.size.height <= 0) {
        return CGSizeZero;
    }

    CGFloat containerWidth = containerSize.width;
    CGFloat containerHeight = containerSize.height;
    if (containerWidth <= 0) {
        containerWidth = CGRectGetWidth(UIScreen.mainScreen.bounds);
    }
    if (containerHeight <= 0) {
        containerHeight = CGRectGetHeight(UIScreen.mainScreen.bounds);
    }

    CGFloat maxWidth = MAX(containerWidth - horizontalMarginTotal, 1);
    // 最大高度按屏幕计算，避免弹框内容增高/倒计时刷新导致 container 变矮后图片反复缩小
    CGFloat maxHeight = MAX(CGRectGetHeight(UIScreen.mainScreen.bounds) * maxHeightRatio, 1);
    CGFloat aspect = image.size.height / image.size.width;

    CGFloat width = maxWidth;
    CGFloat height = width * aspect;
    if (height > maxHeight) {
        height = maxHeight;
    }
    return CGSizeMake(width, height);
}

+ (void)updateImageView:(UIImageView *)imageView
              withImage:(UIImage *)image
          containerView:(UIView *)containerView
    horizontalMarginTotal:(CGFloat)horizontalMarginTotal
         maxHeightRatio:(CGFloat)maxHeightRatio {
    CGSize size = [self displaySizeForImage:image
                              containerSize:containerView.bounds.size
                       horizontalMarginTotal:horizontalMarginTotal
                             maxHeightRatio:maxHeightRatio];
    if (size.width <= 0 || size.height <= 0) {
        return;
    }

    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
        make.height.mas_equalTo(size.height);
    }];
    [containerView setNeedsLayout];
    [containerView layoutIfNeeded];
}

@end
