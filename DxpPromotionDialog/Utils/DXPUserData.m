#import "DXPUserData.h"

@implementation DXPUserData

+ (instancetype)sharedInstance {
    static DXPUserData *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DXPUserData alloc] init];
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
