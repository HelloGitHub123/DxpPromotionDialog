#import "DXPBasePromotionViewController.h"
#import "DXPPopUp.h"
#import "DXPPromotionInfo.h"

@implementation DXPBasePromotionViewController

- (DXPPopUp *)buildPopUpWithJumpUrl:(NSString *)jumpUrl transactionSn:(NSString *)transactionSn {
    DXPPopUp *pop = [[DXPPopUp alloc] init];
    pop.jumpUrl = jumpUrl;
    pop.transactionSn = transactionSn;
    return pop;
}

- (DXPPopUp *)buildPopUpWithPromotionInfo:(DXPPromotionInfo *)info jumpUrl:(NSString *)jumpUrl {
    return [DXPPopUp popUpWithPromotionInfo:info jumpUrl:jumpUrl];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.isBeingDismissed && self.onDismissBlock) {
        self.onDismissBlock();
    }
}

@end
