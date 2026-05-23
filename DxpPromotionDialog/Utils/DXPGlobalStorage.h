#import <Foundation/Foundation.h>

@class DXPSDKConfig;

NS_ASSUME_NONNULL_BEGIN

/// Demo 占位，对应 Android DxpGlobalStorage
@interface DXPGlobalStorage : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy, nullable) NSString *dxpUrl;
@property (nonatomic, assign, getter=isInitialized) BOOL initialized;
@property (nonatomic, strong, nullable) DXPSDKConfig *sdkConfig;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
