#import "DXPPopUp.h"
#import "DXPPromotionInfo.h"
#import "DXPMktCreativeInfo.h"
#import "DXPPopupModel.h"

@interface DXPPopUp ()
@property (nonatomic, copy, readwrite, nullable) NSDictionary *popupData;
@property (nonatomic, strong, readwrite, nullable) DXPPopupModel *popupModel;
@end

@implementation DXPPopUp

+ (instancetype)popUpWithPromotionInfo:(DXPPromotionInfo *)info jumpUrl:(NSString *)jumpUrl {
    DXPPopUp *pop = [[DXPPopUp alloc] init];
    pop.jumpUrl = jumpUrl;
    pop.transactionSn = info.transactionSn;
    DXPPopupModel *popup = info.mktCreativeInfo.popup;
    if (popup.rawDictionary) {
        pop.popupData = [popup.rawDictionary copy];
        pop.popupModel = popup;
    }
    return pop;
}

@end
