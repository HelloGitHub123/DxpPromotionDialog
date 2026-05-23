#import "DXPQueryAllChannelsResp.h"
#import "DXPJSONHelper.h"

@implementation DXPQueryAllChannelsResp

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    DXPQueryAllChannelsResp *m = [[DXPQueryAllChannelsResp alloc] init];
    m.resultCode = [DXPJSONHelper stringValue:dict[@"resultCode"]];
    m.resultMsg = [DXPJSONHelper stringValue:dict[@"resultMsg"]];
    return m;
}

@end
