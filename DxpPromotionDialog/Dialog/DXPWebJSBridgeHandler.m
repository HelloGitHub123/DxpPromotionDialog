#import "DXPWebJSBridgeHandler.h"
#import "DXPPromoUserData.h"
#import <UIKit/UIKit.h>

@implementation DXPWebJSBridgeHandler

+ (NSString *)userInfoJSONString {
    DXPPromoUserData *user = [DXPPromoUserData sharedInstance];
    NSDictionary *params = @{
        @"token": user.token ?: @"",
        @"phone": user.serviceNumber ?: @"",
        @"language": @"en",
        @"acctId": @"",
        @"platform": @"ios",
        @"email": @"",
        @"subsId": user.subsId ? user.subsId.stringValue : @"",
        @"version": [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"",
        @"custId": user.custNbr ?: @"",
        @"prefix": @"",
        @"userId": @"",
        @"userName": @"",
        @"currentAccNbr": user.serviceNumber ?: @""
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"{}";
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // WKScriptMessageHandler for clp bridge if H5 calls native directly
}

@end
