#import "DXPPromotionManager.h"
#import "DXPPromotionInfo.h"
#import "DXPWebPromotionInfo.h"
#import "DXPPopUp.h"
#import "DXPMktContactDto.h"
#import "DXPMktCreativeInfo.h"
#import "DXPPopupModel.h"
#import "DXPQueryPromotionsResp.h"
#import "DXPPromotionAPIClient.h"
#import "DXPToolsLoadingHelper.h"
#import "DXPGlobalStorage.h"
#import "DXPPromoUserData.h"
#import "DXPJSONHelper.h"
#import "DXPPromotionTags.h"
#import "DXPImagePromotionViewController.h"
#import "DXPWebPromotionViewController.h"
#import "DXPPopupPromotionViewController.h"
#import "DXPMultiPromotionViewController.h"
#import <DXPNetWorkingManagerLib/DCNetAPIClient.h>

@interface DXPPromotionManager () <DXPPromotionDialogDelegate>
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<DXPPromotionInfo *> *> *promotionData;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<DXPPromotionInfo *> *> *popupPromotionData;
@property (nonatomic, strong) NSMutableArray<DXPPromotionInfo *> *forcePromotionData;
@property (nonatomic, strong) NSMutableArray<DXPPromotionInfo *> *forcePopupPromotionData;
@property (nonatomic, assign) BOOL isPromotionDataComplete;
@property (nonatomic, strong, nullable) NSTimer *pollTimer;
@property (nonatomic, assign) NSInteger pollCount;
@property (nonatomic, weak, nullable) UIViewController *pendingViewController;
@end

@implementation DXPPromotionManager

+ (instancetype)sharedManager {
    static DXPPromotionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DXPPromotionManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _promotionData = [NSMutableDictionary dictionary];
        _popupPromotionData = [NSMutableDictionary dictionary];
        _forcePromotionData = [NSMutableArray array];
        _forcePopupPromotionData = [NSMutableArray array];
        NSLog(@"[%@] SDK init", DXPPromotionTagMain);
    }
    return self;
}

- (void)initSDK {
//    if (![DXPGlobalStorage sharedInstance].isInitialized) {
//        @throw [NSException exceptionWithName:NSInternalInconsistencyException
//                                       reason:@"DxpSdk not initialized. Please configure DXPGlobalStorage first."
//                                     userInfo:nil];
//    }
}

- (void)setPromotionLifecycleListener:(id<DXPPromotionLifecycleDelegate>)listener {
    self.lifecycleDelegate = listener;
}

+ (void)notifyViewControllerDidAppear:(UIViewController *)viewController {
    [[self sharedManager] processPromotionVisibilityOnViewController:viewController];
}

#pragma mark - Query

- (void)queryDxpPromotionDialogPoll {
    NSString *dxpUrl = [DCNetAPIClient sharedClient].baseUrl;
    if ([DXPJSONHelper isEmptyString:dxpUrl]) {
        NSLog(@"[%@] DXP URL is null", DXPPromotionTagMain);
        return;
    }
    self.isPromotionDataComplete = NO;
    if (self.pollTimer) return;
    self.pollCount = 0;
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:YES block:^(NSTimer *timer) {
        if (self.pollCount >= 6) {
            [self cancelPoll];
            NSLog(@"[%@] polling limit exceeded", DXPPromotionTagMain);
            return;
        }
        NSLog(@"[%@] polling attempt #%ld", DXPPromotionTagMain, (long)self.pollCount);
        [self queryPromotionDataWithListener:^(BOOL success) {
            if (success) {
                [self cancelPoll];
                [self processPromotionVisibility];
            }
        }];
        self.pollCount++;
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.pollTimer forMode:NSRunLoopCommonModes];
    [self.pollTimer fire];
}

- (void)cancelPoll {
    [self.pollTimer invalidate];
    self.pollTimer = nil;
}

- (void)queryDxpPromotionDialogOnce {
    self.isPromotionDataComplete = NO;
    __weak typeof(self) weakSelf = self;
    [self queryPromotionDataWithListener:^(BOOL success) {
        if (!success) return;
        UIViewController *top = [DXPPromotionManager topViewController];
        if ([weakSelf isViewControllerFinished:top]) return;
        [weakSelf processPromotionVisibilityOnViewController:top];
    }];
}

- (void)queryDxpPromotionDialogOnceOnViewController:(UIViewController *)viewController {
    self.isPromotionDataComplete = NO;
    self.pendingViewController = viewController;
    __weak typeof(self) weakSelf = self;
    [self queryPromotionDataWithListener:^(BOOL success) {
        if (!success) return;
        if ([weakSelf isViewControllerFinished:viewController]) return;
        [weakSelf processPromotionVisibilityOnViewController:viewController];
    }];
}

- (void)refreshDataOnViewController:(UIViewController *)viewController completion:(DXPPromotionRefreshBlock)completion {
    self.refreshBlock = completion;
    [self queryDxpPromotionDialogOnceOnViewController:viewController];
}

- (void)showPromotionOnViewController:(UIViewController *)viewController {
    [self processPromotionVisibilityOnViewController:viewController];
}

- (void)queryPromotionDataWithListener:(void(^)(BOOL success))listener {
	NSString *dxpUrl = [DCNetAPIClient sharedClient].baseUrl;
    if ([DXPJSONHelper isEmptyString:dxpUrl]) {
        NSLog(@"[%@] DXP URL is null", DXPPromotionTagMain);
        if (listener) listener(NO);
        return;
    }
    [DXPToolsLoadingHelper showLoading];
    NSNumber *subsId = [DXPPromoUserData sharedInstance].subsId;
    NSString *serviceNumber = [DXPPromoUserData sharedInstance].serviceNumber;
    [[DXPPromotionAPIClient sharedClient] fetchPromotionsWithSubsId:subsId
                                                            channel:@"APP"
                                                             adSlot:@"APP_POPUP"
                                                      serviceNumber:serviceNumber
                                                            success:^(DXPQueryPromotionsResp *response) {
        [DXPToolsLoadingHelper hideLoading];
        [self parserPromotionData:response listener:listener];
    } failure:^(NSString *code, NSString *msg) {
        [DXPToolsLoadingHelper hideLoading];
        if (listener) listener(NO);
        if (self.refreshBlock) {
            self.refreshBlock(NO);
            self.refreshBlock = nil;
        }
    }];
}

#pragma mark - Parser

- (void)parserPromotionData:(DXPQueryPromotionsResp *)response listener:(void(^)(BOOL success))listener {
    @synchronized (self) {
        if (self.isPromotionDataComplete) return;
        if (response.data.count > 0) {
            [self.promotionData removeAllObjects];
            [self.forcePromotionData removeAllObjects];
            [self.popupPromotionData removeAllObjects];
            [self.forcePopupPromotionData removeAllObjects];

			NSArray<NSString *> *exclude = @[]; //[DXPGlobalStorage sharedInstance].sdkConfig.promotionDialogConfig.excludePageName;

            for (DXPMktContactDto *dto in response.data) {
                if (dto.recommendedWordsList.count == 0) continue;
                DXPMktCreativeInfo *creative = dto.recommendedWordsList.firstObject;
                NSString *pageUrl = creative.popupPageURL;

                if (exclude.count > 0) {
                    BOOL skip = NO;
                    for (NSString *name in exclude) {
                        if ([DXPJSONHelper string:name equals:pageUrl]) { skip = YES; break; }
                    }
                    if (skip) continue;
                }

                DXPPromotionInfo *info = [[DXPPromotionInfo alloc] init];
                info.transactionSn = dto.contactId.stringValue;
                info.batchId = dto.batchId.stringValue;
                info.campaignCode = dto.campaignCode;
                info.mktCreativeInfo = creative;
                info.popupPageURL = pageUrl;

                if ([DXPJSONHelper isEmptyString:pageUrl]) {
                    if (creative.popup.rawDictionary == nil) {
                        if ([DXPJSONHelper string:creative.creativeType equals:@"2"]) {
                            NSString *url = [NSString stringWithFormat:@"%@?code=%@&source=APP", creative.serverUrl ?: @"", creative.creativeCode ?: @""];
                            DXPWebPromotionInfo *web = [[DXPWebPromotionInfo alloc] init];
                            web.batchId = info.batchId;
                            web.campaignCode = info.campaignCode;
                            web.mktCreativeInfo = creative;
                            web.popupPageURL = pageUrl;
                            web.transactionSn = info.transactionSn;
                            web.webUrl = url;
                            [self.forcePromotionData addObject:web];
                        } else {
                            [self.forcePromotionData addObject:info];
                        }
                    } else {
                        [self.forcePopupPromotionData addObject:info];
                    }
                } else {
                    [self addPromotionInfo:info toMap:self.popupPromotionData key:pageUrl];
                    [self addPromotionInfo:info toMap:self.promotionData key:pageUrl];
                }
            }
        }

        BOOL hasData = self.promotionData.count > 0 || self.forcePromotionData.count > 0 ||
                       self.popupPromotionData.count > 0 || self.forcePopupPromotionData.count > 0;
        if (hasData) {
            if (listener) listener(YES);
            if (self.refreshBlock) {
                self.refreshBlock(YES);
                self.refreshBlock = nil;
            }
            self.isPromotionDataComplete = YES;
        } else {
            if (listener) listener(NO);
        }
    }
}

- (void)addPromotionInfo:(DXPPromotionInfo *)info toMap:(NSMutableDictionary *)map key:(NSString *)key {
    NSMutableArray *list = map[key];
    if (!list) {
        list = [NSMutableArray array];
        map[key] = list;
    }
    [list addObject:info];
}

#pragma mark - Visibility

- (void)processPromotionVisibility {
    UIViewController *top = [DXPPromotionManager topViewController];
    if ([self isViewControllerFinished:top]) return;
    [self processPromotionVisibilityOnViewController:top];
}

- (void)processPromotionVisibilityOnViewController:(UIViewController *)viewController {
    if ([self isViewControllerFinished:viewController]) return;
    NSString *filterName = NSStringFromClass([viewController class]);
    NSLog(@"[%@] current vc name -> %@", DXPPromotionTagMain, filterName);

    NSMutableArray *popupList = self.popupPromotionData[filterName];
    if (popupList.count > 0) {
        [self showPromotionPopupDialogOn:viewController info:popupList.firstObject];
        return;
    }

    NSMutableArray *promoList = self.promotionData[filterName];
    if (promoList.count > 0) {
        if (promoList.count == 1) {
            DXPPromotionInfo *info = promoList.firstObject;
            if ([DXPJSONHelper string:info.mktCreativeInfo.creativeType equals:@"2"]) {
                [self showPromotionWebDialogOn:viewController info:info];
            } else {
                [self showPromotionImageDialogOn:viewController info:info];
            }
        } else {
            [self showMultiPromotionDialogOn:viewController list:[promoList copy]];
            [self.promotionData removeObjectForKey:filterName];
        }
        return;
    }

    if (self.forcePopupPromotionData.count > 0) {
        [self showPromotionPopupDialogOn:viewController info:self.forcePopupPromotionData.firstObject];
        return;
    }

    if (self.forcePromotionData.count > 0) {
        if (self.forcePromotionData.count == 1) {
            DXPPromotionInfo *info = self.forcePromotionData.firstObject;
            if ([DXPJSONHelper string:info.mktCreativeInfo.creativeType equals:@"2"]) {
                [self showPromotionWebDialogOn:viewController info:info];
            } else {
                [self showPromotionImageDialogOn:viewController info:info];
            }
        } else {
            [self showMultiForcePromotionDialogOn:viewController];
        }
    }
}

#pragma mark - Show dialogs

- (DXPPopUp *)buildPopUpFromPromotionInfo:(DXPPromotionInfo *)info jumpUrl:(NSString *)jumpUrl {
    return [DXPPopUp popUpWithPromotionInfo:info jumpUrl:jumpUrl];
}

- (void)showPromotionPopupDialogOn:(UIViewController *)host info:(DXPPromotionInfo *)info {
    DXPPopupPromotionViewController *vc = [[DXPPopupPromotionViewController alloc] initWithPromotionInfo:info];
    vc.dialogDelegate = self;
    __weak typeof(self) weakSelf = self;
    __weak DXPPromotionInfo *weakInfo = info;
    vc.onDismissBlock = ^{
        if ([weakSelf.lifecycleDelegate respondsToSelector:@selector(promotionDidClose:)]) {
            DXPPromotionInfo *promotionInfo = weakInfo;
            if (promotionInfo) {
                [weakSelf.lifecycleDelegate promotionDidClose:[weakSelf buildPopUpFromPromotionInfo:promotionInfo jumpUrl:nil]];
            }
        }
        [weakSelf processPromotionVisibility];
    };
    [self presentDialog:vc on:host];
    [self reportingOpenWithInfo:info];
    if (![DXPJSONHelper isEmptyString:info.popupPageURL]) {
        [self.popupPromotionData removeObjectForKey:info.popupPageURL];
    }
    [self.forcePopupPromotionData removeObject:info];
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidShow:)]) {
        [self.lifecycleDelegate promotionDidShow:[self buildPopUpFromPromotionInfo:info jumpUrl:info.mktCreativeInfo.jumpLink]];
    }
}

- (void)showPromotionWebDialogOn:(UIViewController *)host info:(DXPPromotionInfo *)info {
    NSString *url = [NSString stringWithFormat:@"%@?code=%@&source=APP",
                     info.mktCreativeInfo.serverUrl ?: @"", info.mktCreativeInfo.creativeCode ?: @""];
    DXPWebPromotionViewController *vc = [[DXPWebPromotionViewController alloc] initWithURL:url];
    [self presentDialog:vc on:host];
    [self reportingOpenWithInfo:info];
    [self removeShownInfo:info];
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidShow:)]) {
        [self.lifecycleDelegate promotionDidShow:[[DXPPopUp alloc] init]];
    }
}

- (void)showPromotionImageDialogOn:(UIViewController *)host info:(DXPPromotionInfo *)info {
    DXPImagePromotionViewController *vc = [[DXPImagePromotionViewController alloc] initWithPromotionInfo:info];
    vc.dialogDelegate = self;
    [self presentDialog:vc on:host];
    [self reportingOpenWithInfo:info];
    [self removeShownInfo:info];
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidShow:)]) {
        [self.lifecycleDelegate promotionDidShow:[self buildPopUpFromPromotionInfo:info jumpUrl:info.mktCreativeInfo.jumpLink]];
    }
}

- (void)showMultiPromotionDialogOn:(UIViewController *)host list:(NSArray<DXPPromotionInfo *> *)list {
    DXPMultiPromotionViewController *vc = [[DXPMultiPromotionViewController alloc] initWithPromotionList:list];
    vc.dialogDelegate = self;
    [self presentDialog:vc on:host];
    for (DXPPromotionInfo *info in list) {
        [self reportingOpenWithInfo:info];
    }
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidShow:)]) {
        [self.lifecycleDelegate promotionDidShow:[[DXPPopUp alloc] init]];
    }
}

- (void)showMultiForcePromotionDialogOn:(UIViewController *)host {
    DXPMultiPromotionViewController *vc = [[DXPMultiPromotionViewController alloc] initWithPromotionList:[self.forcePromotionData copy]];
    vc.dialogDelegate = self;
    [self presentDialog:vc on:host];
    for (DXPPromotionInfo *info in self.forcePromotionData) {
        [self reportingOpenWithInfo:info];
    }
    [self.forcePromotionData removeAllObjects];
    [self.promotionData removeAllObjects];
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidShow:)]) {
        [self.lifecycleDelegate promotionDidShow:[[DXPPopUp alloc] init]];
    }
}

- (void)presentDialog:(UIViewController *)dialog on:(UIViewController *)host {
    dialog.modalPresentationStyle = UIModalPresentationOverFullScreen;
    dialog.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [host presentViewController:dialog animated:YES completion:nil];
}

- (void)removeShownInfo:(DXPPromotionInfo *)info {
    if (![DXPJSONHelper isEmptyString:info.popupPageURL]) {
        [self.promotionData removeObjectForKey:info.popupPageURL];
    }
    [self.forcePromotionData removeObject:info];
}

#pragma mark - Reporting

- (void)reportingOpenWithInfo:(DXPPromotionInfo *)info {
    DXPPopUp *pop = [[DXPPopUp alloc] init];
    pop.transactionSn = info.transactionSn;
    [self reportingOpenWithPopUp:pop];
}

- (void)reportingOpenWithPopUp:(DXPPopUp *)popUp {
    [[DXPPromotionAPIClient sharedClient] reportStatusWithTransactionSn:popUp.transactionSn
                                                                 status:@"1"
                                                                success:^(DXPQueryAllChannelsResp *r) {}
                                                                failure:^(NSString *c, NSString *m) {}];
}

- (void)reportingClickWithPopUp:(DXPPopUp *)popUp {
    [[DXPPromotionAPIClient sharedClient] reportStatusWithTransactionSn:popUp.transactionSn
                                                                 status:@"2"
                                                                success:^(DXPQueryAllChannelsResp *r) {}
                                                                failure:^(NSString *c, NSString *m) {}];
}

#pragma mark - DXPPromotionDialogDelegate

- (void)promotionDialogDidPopClick:(DXPPopUp *)popUp {
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidClick:)]) {
        [self.lifecycleDelegate promotionDidClick:popUp];
    }
    [self reportingClickWithPopUp:popUp];
}

- (void)promotionDialogDidCloseClick:(DXPPopUp *)popUp {
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidClose:)]) {
        [self.lifecycleDelegate promotionDidClose:popUp];
    }
}

- (void)notifyButtonClick:(DXPPopUp *)popUp {
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidButtonClick:)]) {
        [self.lifecycleDelegate promotionDidButtonClick:popUp];
    }
    [self reportingClickWithPopUp:popUp];
}

- (void)promotionDialogDidPrimaryClick:(DXPPopUp *)popUp {
    [self notifyButtonClick:popUp];
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidPrimaryButtonClick:)]) {
        [self.lifecycleDelegate promotionDidPrimaryButtonClick:popUp];
    }
}

- (void)promotionDialogDidSecondaryClick:(DXPPopUp *)popUp {
    [self notifyButtonClick:popUp];
    if ([self.lifecycleDelegate respondsToSelector:@selector(promotionDidSecondaryButtonClick:)]) {
        [self.lifecycleDelegate promotionDidSecondaryButtonClick:popUp];
    }
}

#pragma mark - Helpers

- (BOOL)isViewControllerFinished:(UIViewController *)vc {
    if (!vc) return YES;
    if (vc.isBeingDismissed || vc.isMovingFromParentViewController) return YES;
    return NO;
}

+ (UIViewController *)topViewController {
    UIViewController *root = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive &&
                [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *ws = (UIWindowScene *)scene;
                for (UIWindow *w in ws.windows) {
                    if (w.isKeyWindow) { root = w.rootViewController; break; }
                }
            }
        }
    }
    if (!root) {
        root = UIApplication.sharedApplication.keyWindow.rootViewController;
    }
    return [self topViewControllerFrom:root];
}

+ (UIViewController *)topViewControllerFrom:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self topViewControllerFrom:[(UINavigationController *)vc visibleViewController]];
    }
    if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self topViewControllerFrom:[(UITabBarController *)vc selectedViewController]];
    }
    if (vc.presentedViewController) {
        return [self topViewControllerFrom:vc.presentedViewController];
    }
    return vc;
}

@end
