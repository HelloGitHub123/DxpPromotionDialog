#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Demo 占位，对应 Android DxpUserData。集成时替换为真实 Base SDK。
@interface DXPPromoUserData : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, nullable) NSNumber *subsId;
@property (nonatomic, copy, nullable) NSString *serviceNumber;
@property (nonatomic, copy, nullable) NSString *token;
@property (nonatomic, copy, nullable) NSString *custNbr;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
