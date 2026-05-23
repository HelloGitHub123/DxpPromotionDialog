#import "DXPMktContactDto.h"
#import "DXPMktCreativeInfo.h"
#import "DXPJSONHelper.h"

@implementation DXPMktContactDto

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    DXPMktContactDto *m = [[DXPMktContactDto alloc] init];
    m.subsId = [DXPJSONHelper numberValue:dict[@"subsId"]];
    m.serviceNumber = [DXPJSONHelper stringValue:dict[@"serviceNumber"]];
    m.channel = [DXPJSONHelper stringValue:dict[@"channel"]];
    m.adSlot = [DXPJSONHelper stringValue:dict[@"adSlot"]];
    m.contactId = [DXPJSONHelper numberValue:dict[@"contactId"]];
    m.batchId = [DXPJSONHelper numberValue:dict[@"batchId"]];
    m.batchCode = [DXPJSONHelper stringValue:dict[@"batchCode"]];
    m.campaignCode = [DXPJSONHelper stringValue:dict[@"campaignCode"]];
    m.campaignName = [DXPJSONHelper stringValue:dict[@"campaignName"]];
    NSArray *list = [DXPJSONHelper arrayValue:dict[@"recommendedWordsList"]];
    if (list.count > 0) {
        NSMutableArray *creatives = [NSMutableArray array];
        for (id item in list) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                DXPMktCreativeInfo *c = [DXPMktCreativeInfo modelWithDictionary:item];
                if (c) [creatives addObject:c];
            }
        }
        m.recommendedWordsList = creatives;
    }
    return m;
}

@end
