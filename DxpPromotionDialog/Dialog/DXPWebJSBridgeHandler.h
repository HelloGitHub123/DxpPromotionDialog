#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DXPWebJSBridgeHandler : NSObject <WKScriptMessageHandler>
+ (NSString *)userInfoJSONString;
@end

NS_ASSUME_NONNULL_END
