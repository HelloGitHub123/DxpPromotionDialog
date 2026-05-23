#import "DXPToolsLoadingHelper.h"
#import <UIKit/UIKit.h>

@implementation DXPToolsLoadingHelper

+ (void)showLoading {
#if __has_include(<DXPToolsLib/DXPLoadingView.h>)
    Class cls = NSClassFromString(@"DXPLoadingView");
    if (cls && [cls respondsToSelector:@selector(showLoading)]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [cls performSelector:@selector(showLoading)];
        #pragma clang diagnostic pop
        return;
    }
#endif
#if __has_include(<DXPToolsLib/DXPToolsManager.h>)
    id manager = [NSClassFromString(@"DXPToolsManager") performSelector:@selector(sharedManager)];
    if (manager && [manager respondsToSelector:@selector(showLoading)]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [manager performSelector:@selector(showLoading)];
        #pragma clang diagnostic pop
    }
#endif
}

+ (void)hideLoading {
#if __has_include(<DXPToolsLib/DXPLoadingView.h>)
    Class cls = NSClassFromString(@"DXPLoadingView");
    if (cls && [cls respondsToSelector:@selector(hideLoading)]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [cls performSelector:@selector(hideLoading)];
        #pragma clang diagnostic pop
        return;
    }
#endif
#if __has_include(<DXPToolsLib/DXPToolsManager.h>)
    id manager = [NSClassFromString(@"DXPToolsManager") performSelector:@selector(sharedManager)];
    if (manager && [manager respondsToSelector:@selector(hideLoading)]) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [manager performSelector:@selector(hideLoading)];
        #pragma clang diagnostic pop
    }
#endif
}

@end
