#import <UIKit/UIKit.h>
#import "DXPPromotionDialogDelegate.h"

@class DXPPromotionInfo;

NS_ASSUME_NONNULL_BEGIN

@interface DXPImagePromotionCell : UICollectionViewCell

@property (nonatomic, weak, nullable) id<DXPPromotionDialogDelegate> dialogDelegate;

- (void)configureWithInfo:(DXPPromotionInfo *)info;

@end

NS_ASSUME_NONNULL_END
