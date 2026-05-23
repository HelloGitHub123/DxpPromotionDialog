#import "DXPBasePromotionViewController.h"

@class DXPPromotionInfo;

NS_ASSUME_NONNULL_BEGIN

@interface DXPMultiPromotionViewController : DXPBasePromotionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (instancetype)initWithPromotionList:(NSArray<DXPPromotionInfo *> *)list;

@end

NS_ASSUME_NONNULL_END
