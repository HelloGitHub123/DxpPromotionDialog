#import "DXPChannelReq.h"

@implementation DXPChannelReq

- (NSDictionary *)toDictionary {
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    if (self.transactionSn) d[@"transactionSn"] = self.transactionSn;
    if (self.status) d[@"status"] = self.status;
    return d;
}

@end
