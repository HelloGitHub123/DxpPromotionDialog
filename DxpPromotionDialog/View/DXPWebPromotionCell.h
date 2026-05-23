#import <UIKit/UIKit.h>

@class DXPWebPromotionInfo;
@protocol DXPPromotionDialogDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface DXPWebPromotionCell : UICollectionViewCell

@property (nonatomic, weak, nullable) id<DXPPromotionDialogDelegate> dialogDelegate;

- (void)configureWithInfo:(DXPWebPromotionInfo *)info;

@end

NS_ASSUME_NONNULL_END
