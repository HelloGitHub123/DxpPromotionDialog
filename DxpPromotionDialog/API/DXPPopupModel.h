#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 对应 Android Popup，基于 JSON 字典访问嵌套字段
@interface DXPPopupModel : NSObject

@property (nonatomic, copy, readonly, nullable) NSDictionary *rawDictionary;

+ (instancetype)modelWithDictionary:(nullable NSDictionary *)dict;

- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dict;

- (nullable NSString *)popupType;
- (nullable NSString *)appFramePosition;
- (nullable NSDictionary *)appFrameStyle;
/// appFrame.style.background 或 appFrame.background
- (nullable NSDictionary *)appFrameBackground;
/// appFrame.style.backdrop 或 appFrame.backdrop
- (nullable NSDictionary *)appFrameBackdrop;
- (nullable NSString *)titleContent;
- (nullable NSDictionary *)titleStyle;
- (nullable NSDictionary *)messageStyle;
- (nullable NSString *)messageContent;

- (nullable NSString *)mediaType;
- (nullable NSString *)mediaURL;
- (nullable NSString *)mediaLink;
- (nullable NSDictionary *)mediaPaddingStyle;
/// button.arrangement，默认 inline（主/副按钮同一行）
- (NSString *)buttonArrangement;
/// button.layout：autoRight / autoMiddle(默认) / autoLeft / fullWidth
- (NSString *)buttonLayout;
- (NSInteger)buttonMinWidth;
- (nullable NSDictionary *)primaryButtonStyle;
- (nullable NSDictionary *)secondaryButtonStyle;
- (nullable NSString *)primaryButtonFilledColor;
- (CGFloat)primaryButtonCorner;
- (nullable NSDictionary *)primaryButtonBorderStyle;
- (nullable NSDictionary *)primaryButtonFontStyle;
- (nullable NSString *)primaryButtonText;
- (nullable NSString *)primaryButtonLink;

- (nullable NSString *)secondaryButtonFilledColor;
- (CGFloat)secondaryButtonCorner;
- (nullable NSDictionary *)secondaryButtonBorderStyle;
- (nullable NSDictionary *)secondaryButtonFontStyle;
- (nullable NSString *)secondaryButtonText;
- (nullable NSString *)secondaryButtonLink;

/// dismissal.closeButton.enabled 是否展示关闭按钮
- (BOOL)closeButtonEnabled;
- (nullable NSDictionary *)closeButtonStyle;
/// dismissal.closeButton.style.type：line 无背景，filled 圆形背景且 X 镂空透明
- (NSString *)closeButtonStyleType;
- (NSInteger)closeButtonSize;
- (nullable NSString *)closeButtonColor;
/// dismissal.closeOnBackdrop 是否点击背景（遮罩）关闭弹窗
- (BOOL)closeOnBackdrop;
- (BOOL)countDownEnabled;
- (NSInteger)countDownSeconds;
- (nullable NSDictionary *)countDownStyle;

- (nullable id)valueForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
