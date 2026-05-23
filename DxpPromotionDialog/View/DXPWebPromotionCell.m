#import "DXPWebPromotionCell.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>
#import "DXPWebPromotionInfo.h"
#import "DXPWebJSBridgeHandler.h"

@interface DXPWebPromotionCell ()
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation DXPWebPromotionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        WKUserContentController *ucc = [[WKUserContentController alloc] init];
        NSString *js = [NSString stringWithFormat:@"window.clp = { getUserInfo: function() { return %@; } };",
                          [DXPWebJSBridgeHandler userInfoJSONString]];
        [ucc addUserScript:[[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.userContentController = ucc;
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        [self.contentView addSubview:_webView];
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)configureWithInfo:(DXPWebPromotionInfo *)info {
    NSURL *url = [NSURL URLWithString:info.webUrl ?: @""];
    if (url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

@end
