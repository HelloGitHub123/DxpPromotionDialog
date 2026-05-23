#import "DXPImagePromotionViewController.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "DXPPromotionInfo.h"
#import "DXPMktCreativeInfo.h"
#import "DXPPromotionTags.h"
#import "DXPPromotionImageLayoutHelper.h"

static const CGFloat kDXPImageDialogHorizontalInset = 24.0;
static const CGFloat kDXPImageDialogMaxHeightRatio = 0.75;

@interface DXPImagePromotionViewController ()
@property (nonatomic, strong) DXPPromotionInfo *promotionInfo;
@property (nonatomic, strong) UIImageView *contentImageView;
@property (nonatomic, strong) UIButton *closeButton;
@end

@implementation DXPImagePromotionViewController

- (instancetype)initWithPromotionInfo:(DXPPromotionInfo *)info {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _promotionInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    self.contentImageView = [[UIImageView alloc] init];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.contentImageView.clipsToBounds = YES;
    self.contentImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapped)];
    [self.contentImageView addGestureRecognizer:tap];

    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:22 weight:UIFontWeightMedium];
    [self.closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.contentImageView];
    [self.view addSubview:self.closeButton];

    [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(1);
    }];

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentImageView.mas_bottom).offset(40);
        make.centerX.mas_equalTo(self.contentImageView);
        make.width.height.mas_equalTo(34);
    }];

    BOOL showClose = self.promotionInfo.mktCreativeInfo.showCloseButton.boolValue;
    self.closeButton.hidden = !showClose;

    __weak typeof(self) weakSelf = self;
    [self.contentImageView sd_setImageWithURL:[NSURL URLWithString:self.promotionInfo.mktCreativeInfo.thumbnail ?: @""]
                             placeholderImage:nil
                                      options:SDWebImageRetryFailed
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !image) return;
        [self updateContentImageLayoutWithImage:image];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.contentImageView.image) {
        [self updateContentImageLayoutWithImage:self.contentImageView.image];
    }
}

- (void)updateContentImageLayoutWithImage:(UIImage *)image {
        [DXPPromotionImageLayoutHelper updateImageView:self.contentImageView
                                             withImage:image
                                         containerView:self.view
                               horizontalMarginTotal:kDXPImageDialogHorizontalInset * 2
                                      maxHeightRatio:kDXPImageDialogMaxHeightRatio];
}

- (void)contentTapped {
    NSLog(@"[%@] promotion is click", DXPPromotionTagImage);
    DXPPopUp *pop = [self buildPopUpWithPromotionInfo:self.promotionInfo
                                              jumpUrl:self.promotionInfo.mktCreativeInfo.jumpLink];
    if ([self.dialogDelegate respondsToSelector:@selector(promotionDialogDidPopClick:)]) {
        [self.dialogDelegate promotionDialogDidPopClick:pop];
    }
}

- (void)closeTapped {
    DXPPopUp *pop = [self buildPopUpWithPromotionInfo:self.promotionInfo jumpUrl:nil];
    if ([self.dialogDelegate respondsToSelector:@selector(promotionDialogDidCloseClick:)]) {
        [self.dialogDelegate promotionDialogDidCloseClick:pop];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
