#import "DXPPromotionInfo.h"
#import "DXPMktCreativeInfo.h"

@implementation DXPPromotionInfo

- (DXPMktCreativeInfo *)mktCreativeInfo {
    return _mktCreativeInfo ?: [[DXPMktCreativeInfo alloc] init];
}

@end
