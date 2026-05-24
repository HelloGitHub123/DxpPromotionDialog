#import "DXPGlobalStorage.h"

@implementation DXPGlobalStorage

+ (instancetype)sharedInstance {
    static DXPGlobalStorage *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DXPGlobalStorage alloc] init];
    });
    return instance;
}

- (void)reset {
    self.dxpUrl = nil;
    self.initialized = NO;
}

@end
