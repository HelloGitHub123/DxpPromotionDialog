#import "DXPWebPromotionViewController.h"
#import <Masonry/Masonry.h>
#import <WebKit/WebKit.h>
#import "DXPWebJSBridgeHandler.h"
#import "DXPPromotionTags.h"

@interface DXPWebPromotionViewController () <WKNavigationDelegate>
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation DXPWebPromotionViewController

- (instancetype)initWithURL:(NSString *)url {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _urlString = [url copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;

    WKUserContentController *ucc = [[WKUserContentController alloc] init];
    NSString *js = [NSString stringWithFormat:
        @"window.clp = { getUserInfo: function() { return %@; } };",
        [DXPWebJSBridgeHandler userInfoJSONString]];
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly:YES];
    [ucc addUserScript:script];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = ucc;

    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = UIColor.clearColor;

    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.webView];
    [self.view addSubview:self.closeButton];

    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(16);
        } else {
            make.top.mas_equalTo(self.view).offset(16);
        }
        make.trailing.mas_equalTo(self.view).offset(-16);
    }];

    NSURL *url = [NSURL URLWithString:self.urlString];
    if (url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (void)closeTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *url = navigationAction.request.URL.absoluteString;
    NSLog(@"[%@] redirectUrl---> %@", DXPPromotionTagWeb, url);
    if ([url hasPrefix:@"clp://"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    if (![url hasPrefix:@"http:"] && ![url hasPrefix:@"https:"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
