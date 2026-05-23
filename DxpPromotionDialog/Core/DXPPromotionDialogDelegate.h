#import <Foundation/Foundation.h>

@class DXPPopUp;

NS_ASSUME_NONNULL_BEGIN

@protocol DXPPromotionDialogDelegate <NSObject>
@optional
- (void)promotionDialogDidPopClick:(DXPPopUp *)popUp;
- (void)promotionDialogDidCloseClick:(DXPPopUp *)popUp;
- (void)promotionDialogDidPrimaryClick:(DXPPopUp *)popUp;
- (void)promotionDialogDidSecondaryClick:(DXPPopUp *)popUp;
@end

NS_ASSUME_NONNULL_END
