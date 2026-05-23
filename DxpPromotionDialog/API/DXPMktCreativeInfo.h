#import <Foundation/Foundation.h>

@class DXPPopupModel;

NS_ASSUME_NONNULL_BEGIN

@interface DXPMktCreativeInfo : NSObject

@property (nonatomic, copy, nullable) NSString *recommendedWordsType;
@property (nonatomic, copy, nullable) NSString *recommendedTitle;
@property (nonatomic, copy, nullable) NSString *recommendedSubTitle;
@property (nonatomic, copy, nullable) NSString *recommendedWords;
@property (nonatomic, copy, nullable) NSString *thumbnail;
@property (nonatomic, copy, nullable) NSString *clickAction;
@property (nonatomic, copy, nullable) NSString *jumpLink;
@property (nonatomic, copy, nullable) NSString *linkType;
@property (nonatomic, copy, nullable) NSString *creativeCode;
@property (nonatomic, copy, nullable) NSString *creativeType;
@property (nonatomic, copy, nullable) NSString *serverUrl;
@property (nonatomic, strong, nullable) NSNumber *showCloseButton;
@property (nonatomic, copy, nullable) NSString *popupPageURL;
@property (nonatomic, strong, nullable) DXPPopupModel *popup;

+ (instancetype)modelWithDictionary:(nullable NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
