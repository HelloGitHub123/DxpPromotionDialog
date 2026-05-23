#import "DXPQueryPromotionsResp.h"
#import "DXPMktContactDto.h"
#import "DXPJSONHelper.h"

@implementation DXPQueryPromotionsResp

+ (instancetype)modelWithJSONData:(NSData *)data error:(NSError **)error {
    if (!data) return nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
    if (![json isKindOfClass:[NSDictionary class]]) return nil;
    return [self modelWithDictionary:json];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    DXPQueryPromotionsResp *m = [[DXPQueryPromotionsResp alloc] init];
    m.resultCode = [DXPJSONHelper stringValue:dict[@"resultCode"]];
    m.resultMsg = [DXPJSONHelper stringValue:dict[@"resultMsg"]];
    NSArray *arr = [DXPJSONHelper arrayValue:dict[@"data"]];
    if (arr.count > 0) {
        NSMutableArray *items = [NSMutableArray array];
        for (id item in arr) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                DXPMktContactDto *dto = [DXPMktContactDto modelWithDictionary:item];
                if (dto) [items addObject:dto];
            }
        }
        m.data = items;
    }
    return m;
}

@end
