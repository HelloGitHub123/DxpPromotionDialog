#import <Foundation/Foundation.h>
#import "DXPPopupModel.h"

@class DXPPromotionInfo;

NS_ASSUME_NONNULL_BEGIN

/// 弹窗交互回调数据：埋点字段 + 当前 recommendedWordsList 项下的 popup 配置
@interface DXPPopUp : NSObject

@property (nonatomic, copy, nullable) NSString *jumpUrl;
@property (nonatomic, copy, nullable) NSString *transactionSn;
/// recommendedWordsList[].popup 原始 JSON
@property (nonatomic, copy, readonly, nullable) NSDictionary *popupData;
/// 基于 popupData 解析的模型（只读）
@property (nonatomic, strong, readonly, nullable) DXPPopupModel *popupModel;

+ (instancetype)popUpWithPromotionInfo:(DXPPromotionInfo *)info jumpUrl:(nullable NSString *)jumpUrl;

@end

NS_ASSUME_NONNULL_END
