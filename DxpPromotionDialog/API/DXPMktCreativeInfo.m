#import "DXPMktCreativeInfo.h"
#import "DXPPopupModel.h"
#import "DXPJSONHelper.h"

@implementation DXPMktCreativeInfo

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    DXPMktCreativeInfo *m = [[DXPMktCreativeInfo alloc] init];
    m.recommendedWordsType = [DXPJSONHelper stringValue:dict[@"recommendedWordsType"]];
    m.recommendedTitle = [DXPJSONHelper stringValue:dict[@"recommendedTitle"]];
    m.recommendedSubTitle = [DXPJSONHelper stringValue:dict[@"recommendedSubTitle"]];
    m.recommendedWords = [DXPJSONHelper stringValue:dict[@"recommendedWords"]];
    m.thumbnail = [DXPJSONHelper stringValue:dict[@"thumbnail"]];
    m.clickAction = [DXPJSONHelper stringValue:dict[@"clickAction"]];
    m.jumpLink = [DXPJSONHelper stringValue:dict[@"jumpLink"]];
    m.linkType = [DXPJSONHelper stringValue:dict[@"linkType"]];
    m.creativeCode = [DXPJSONHelper stringValue:dict[@"creativeCode"]];
    m.creativeType = [DXPJSONHelper stringValue:dict[@"creativeType"]];
    m.serverUrl = [DXPJSONHelper stringValue:dict[@"serverUrl"]];
    m.showCloseButton = [DXPJSONHelper numberValue:dict[@"showCloseButton"]];
//	m.showCloseButton = @(1);
    m.popupPageURL = [DXPJSONHelper stringValue:dict[@"popupPageUrl"]] ?: [DXPJSONHelper stringValue:dict[@"popupPageURL"]];
    id popupObj = dict[@"popup"];
    if ([popupObj isKindOfClass:[NSDictionary class]]) {
        m.popup = [DXPPopupModel modelWithDictionary:popupObj];
    }
    return m;
}

@end
