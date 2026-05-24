#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Demo 占位，对应 Android DxpGlobalStorage
@interface DXPGlobalStorage : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy, nullable) NSString *dxpUrl;
@property (nonatomic, assign, getter=isInitialized) BOOL initialized;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
