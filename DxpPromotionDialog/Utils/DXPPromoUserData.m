#import "DXPPromoUserData.h"

@implementation DXPPromoUserData

+ (instancetype)sharedInstance {
    static DXPPromoUserData *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DXPPromoUserData alloc] init];
    });
    return instance;
}

- (void)reset {
    self.subsId = nil;
    self.serviceNumber = nil;
    self.token = nil;
    self.custNbr = nil;
}

@end
