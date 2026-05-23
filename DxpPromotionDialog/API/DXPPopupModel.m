#import "DXPPopupModel.h"
#import "DXPJSONHelper.h"

@interface DXPPopupModel ()
@property (nonatomic, copy, readwrite, nullable) NSDictionary *rawDictionary;
@end

@implementation DXPPopupModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _rawDictionary = [dict copy];
    }
    return self;
}

- (id)valueForKeyPath:(NSString *)keyPath {
    if (!self.rawDictionary) return nil;
    return [self.rawDictionary valueForKeyPath:keyPath];
}

- (NSString *)popupType { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"popupType"]]; }
- (NSString *)appFramePosition { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"appFrame.position"]]; }
- (NSDictionary *)appFrameStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"appFrame.style"]]; }

- (NSDictionary *)appFrameBackground {
    NSDictionary *bg = [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"appFrame.style.background"]];
    if (bg) return bg;
    return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"appFrame.background"]];
}

- (NSDictionary *)appFrameBackdrop {
    NSDictionary *backdrop = [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"appFrame.style.backdrop"]];
    if (backdrop) return backdrop;
    return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"appFrame.backdrop"]];
}
- (NSString *)titleContent { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"title.content"]]; }
- (NSDictionary *)titleStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"title.style"]]; }
- (NSDictionary *)messageStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"message.style"]]; }
- (NSString *)messageContent { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"message.content"]]; }
- (NSString *)mediaType { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"media.mediaType"]]; }
- (NSString *)mediaURL { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"media.url"]]; }
- (NSString *)mediaLink { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"media.link"]]; }
- (NSDictionary *)mediaPaddingStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"media.style.padding"]]; }


- (NSString *)buttonArrangement {
    NSString *value = [DXPJSONHelper stringValue:[self valueForKeyPath:@"button.arrangement"]];
    return [DXPJSONHelper isEmptyString:value] ? @"inline" : value;
}

- (NSString *)buttonLayout {
    NSString *value = [DXPJSONHelper stringValue:[self valueForKeyPath:@"button.layout"]];
    return [DXPJSONHelper isEmptyString:value] ? @"autoMiddle" : value;
}

- (NSInteger)buttonMinWidth {
    return [DXPJSONHelper integerValue:[self valueForKeyPath:@"button.minWidth"] defaultValue:0];
}

- (NSDictionary *)primaryButtonStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"button.primaryButton.style"]]; }
- (NSString *)primaryButtonFilledColor { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"button.primaryButton.style.filledColor"]]; }
- (CGFloat)primaryButtonCorner { return (CGFloat)[DXPJSONHelper integerValue:[self valueForKeyPath:@"button.primaryButton.style.buttonCorner"] defaultValue:0]; }
- (NSDictionary *)primaryButtonBorderStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"button.primaryButton.style.borderStyle"]]; }
- (NSDictionary *)primaryButtonFontStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"button.primaryButton.style.fontStyle"]]; }
- (NSString *)primaryButtonText { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"button.primaryButton.text"]]; }
- (NSString *)primaryButtonLink { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"button.primaryButton.link"]]; }

- (NSDictionary *)secondaryButtonStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"button.secondaryButton.style"]]; }
- (NSString *)secondaryButtonFilledColor { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"button.secondaryButton.style.filledColor"]]; }
- (CGFloat)secondaryButtonCorner { return (CGFloat)[DXPJSONHelper integerValue:[self valueForKeyPath:@"button.secondaryButton.style.buttonCorner"] defaultValue:0]; }
- (NSDictionary *)secondaryButtonBorderStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"button.secondaryButton.style.borderStyle"]]; }
- (NSDictionary *)secondaryButtonFontStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"button.secondaryButton.style.fontStyle"]]; }
- (NSString *)secondaryButtonText { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"button.secondaryButton.text"]]; }
- (NSString *)secondaryButtonLink { return [DXPJSONHelper stringValue:[self valueForKeyPath:@"button.secondaryButton.link"]]; }

- (BOOL)closeButtonEnabled {
    return [DXPJSONHelper boolValue:[self valueForKeyPath:@"dismissal.closeButton.enabled"] defaultValue:NO];
}

- (NSDictionary *)closeButtonStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"dismissal.closeButton.style"]]; }

- (NSString *)closeButtonStyleType {
    NSString *type = [DXPJSONHelper stringValue:[self valueForKeyPath:@"dismissal.closeButton.style.type"]];
    return [DXPJSONHelper isEmptyString:type] ? @"line" : type;
}

- (NSInteger)closeButtonSize {
    NSInteger size = [DXPJSONHelper integerValue:[self valueForKeyPath:@"dismissal.closeButton.style.size"] defaultValue:0];
    return size > 0 ? size : 34;
}

- (NSString *)closeButtonColor {
    return [DXPJSONHelper stringValue:[self valueForKeyPath:@"dismissal.closeButton.style.color"]];
}

- (BOOL)closeOnBackdrop { return [DXPJSONHelper boolValue:[self valueForKeyPath:@"dismissal.closeOnBackdrop"] defaultValue:NO]; }
- (BOOL)countDownEnabled { return [DXPJSONHelper boolValue:[self valueForKeyPath:@"dismissal.countDown.enabled"] defaultValue:NO]; }
- (NSInteger)countDownSeconds { return [DXPJSONHelper integerValue:[self valueForKeyPath:@"dismissal.countDown.seconds"] defaultValue:0]; }
- (NSDictionary *)countDownStyle { return [DXPJSONHelper dictionaryValue:[self valueForKeyPath:@"dismissal.countDown.style"]]; }

@end
