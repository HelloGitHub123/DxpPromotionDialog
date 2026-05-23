#import "DXPPopupPromotionViewController.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "DXPPromotionInfo.h"
#import "DXPPopUp.h"
#import "DXPMktCreativeInfo.h"
#import "DXPPopupModel.h"
#import "DXPPromotionColorUtils.h"
#import "DXPJSONHelper.h"
#import "DXPPromotionTags.h"
#import "DXPPromotionImageLayoutHelper.h"

/// 媒体图左右留白（单侧），与 mediaPaddingStyle 叠加
static const CGFloat kDXPPopupMediaHorizontalInset = 16.0;
/// 标题/按钮等内容区左右边距（与 mainTitleLabel 一致）
static const CGFloat kDXPPopupContentHorizontalInset = 16.0;
/// 主副按钮间距（inline 时与左右边距相同）
static const CGFloat kDXPPopupButtonInterSpacing = 16.0;
static const CGFloat kDXPPopupButtonHeight = 44.0;
/// 关闭按钮默认尺寸（style.size 未配置或 ≤0 时使用）
static const CGFloat kDXPPopupCloseButtonDefaultSize = 34.0;
static const CGFloat kDXPPopupCountDownCornerRadius = 12.0;
static const CGFloat kDXPPopupCountDownBorderWidth = 1.0;
/// 媒体图最大高度占 mainView 高度的比例
static const CGFloat kDXPPopupMediaMaxHeightRatio = 0.55;

@interface DXPPopupPromotionViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) DXPPromotionInfo *promotionInfo;
/// 点击跳转与埋点用的弹窗数据模型
@property (nonatomic, strong) DXPPopUp *dxpPopUp;
/// 全屏容器，承载遮罩色与点击关闭手势
@property (nonatomic, strong) UIView *rootView;
/// 弹窗卡片主体（背景、内容、按钮均在其内）
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *mediaImageView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *mainTitleLabel;
@property (nonatomic, strong) UILabel *subsTitleLabel;
@property (nonatomic, strong) UIButton *primaryButton;
@property (nonatomic, strong) UIButton *secondaryButton;
/// 倒计时展示；开启倒计时时会隐藏关闭按钮
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong, nullable) NSTimer *countDownTimer;
/// 点击遮罩关闭（不响应卡片 mainView 区域）
@property (nonatomic, strong) UITapGestureRecognizer *backdropTapGesture;
/// 已按该容器宽度完成媒体图布局，避免重复刷新
@property (nonatomic, assign) CGFloat mediaLayoutContainerWidth;

@end

@implementation DXPPopupPromotionViewController

#pragma mark - Lifecycle

- (instancetype)initWithPromotionInfo:(DXPPromotionInfo *)info {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _promotionInfo = info;
        NSString *defaultLink = info.mktCreativeInfo.jumpLink;
        DXPPopupModel *popup = info.mktCreativeInfo.popup;
        if (![DXPJSONHelper isEmptyString:popup.primaryButtonLink]) {
            defaultLink = popup.primaryButtonLink;
        } else if (![DXPJSONHelper isEmptyString:popup.mediaLink]) {
            defaultLink = popup.mediaLink;
        }
        _dxpPopUp = [DXPPopUp popUpWithPromotionInfo:info jumpUrl:defaultLink];
    }
    return self;
}

- (void)dealloc {
    [self.countDownTimer invalidate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildViews];
    [self refreshMainLayout];
    [self refreshImage];
    [self refreshTitle];
    [self refreshContent];
    [self refreshPrimaryButton];
    [self refreshSecondaryButton];
    [self refreshDismissal];
    [self refreshTimer];
}

#pragma mark - UI Build

/// 创建子视图并设置 Masonry 约束（媒体图宽高在图片加载后由 layout helper 更新）
- (void)buildViews {
    self.rootView = [[UIView alloc] init];
    self.mainView = [[UIView alloc] init];
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.clipsToBounds = YES;

    self.mediaImageView = [[UIImageView alloc] init];
    self.mediaImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.mediaImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mediaTapped)];
    [self.mediaImageView addGestureRecognizer:tap];

    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];

    self.mainTitleLabel = [[UILabel alloc] init];
    self.mainTitleLabel.numberOfLines = 0;
    self.mainTitleLabel.textAlignment = NSTextAlignmentCenter;

    self.subsTitleLabel = [[UILabel alloc] init];
    self.subsTitleLabel.numberOfLines = 0;
    self.subsTitleLabel.textAlignment = NSTextAlignmentCenter;

    self.primaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.primaryButton addTarget:self action:@selector(primaryTapped) forControlEvents:UIControlEventTouchUpInside];

    self.secondaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.secondaryButton addTarget:self action:@selector(secondaryTapped) forControlEvents:UIControlEventTouchUpInside];

    self.timerLabel = [[UILabel alloc] init];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.timerLabel.hidden = YES;

    [self.mainView addSubview:self.backgroundImageView];
    [self.mainView addSubview:self.timerLabel];
    [self.mainView addSubview:self.mediaImageView];
    [self.mainView addSubview:self.closeButton];
    [self.mainView bringSubviewToFront:self.closeButton];
    [self.mainView addSubview:self.mainTitleLabel];
    [self.mainView addSubview:self.subsTitleLabel];
    [self.mainView addSubview:self.primaryButton];
    [self.mainView addSubview:self.secondaryButton];
    [self.rootView addSubview:self.mainView];
    [self.view addSubview:self.rootView];

    self.backdropTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backdropTapped:)];
    self.backdropTapGesture.delegate = self;
    [self.rootView addGestureRecognizer:self.backdropTapGesture];
    self.backdropTapGesture.enabled = NO;

    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.mainView);
    }];

    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];

    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.rootView).offset(24);
        make.trailing.mas_equalTo(self.rootView).offset(-24);
        make.centerY.mas_equalTo(self.rootView);
    }];

    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainView).offset(8);
        make.trailing.mas_equalTo(self.mainView).offset(-12);
        make.leading.mas_greaterThanOrEqualTo(self.mainView).offset(12);
        make.height.mas_greaterThanOrEqualTo(24);
    }];

    [self.mediaImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainView);
        make.leading.mas_equalTo(self.mainView);
        make.trailing.mas_equalTo(self.mainView);
        make.height.mas_equalTo(1);
    }];

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainView).offset(8);
        make.trailing.mas_equalTo(self.mainView).offset(-8);
        make.width.height.mas_equalTo(34);
    }];

    [self.mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mediaImageView.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.mainView).offset(kDXPPopupContentHorizontalInset);
        make.trailing.mas_equalTo(self.mainView).offset(-kDXPPopupContentHorizontalInset);
    }];

    [self.subsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainTitleLabel.mas_bottom).offset(8);
        make.leading.trailing.mas_equalTo(self.mainTitleLabel);
    }];
}

#pragma mark - Data

/// 当前弹窗的创意配置（来自 promotionInfo.mktCreativeInfo）
- (DXPPopupModel *)popup {
    return self.promotionInfo.mktCreativeInfo.popup;
}

#pragma mark - Refresh UI

/// 应用 appFrame：卡片背景（色值 percent/100 透明度）、遮罩 backdrop、居中或 bottom 位置
- (void)refreshMainLayout {
    DXPPopupModel *p = [self popup];
    NSDictionary *bg = p.appFrameBackground;
    NSString *bgType = [DXPJSONHelper stringValue:bg[@"type"]];
    if ([DXPJSONHelper string:bgType equals:@"image"]) {
        NSString *url = [DXPJSONHelper stringValue:bg[@"url"]];
        self.backgroundImageView.hidden = NO;
        self.mainView.backgroundColor = UIColor.clearColor;
        [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:url ?: @""]
                                    placeholderImage:nil
                                             options:SDWebImageRetryFailed];
        self.mainView.layer.cornerRadius = [DXPJSONHelper integerValue:bg[@"corner"] defaultValue:12];
        self.mainView.clipsToBounds = YES;
    } else {
        self.backgroundImageView.hidden = YES;
        NSString *color = [DXPJSONHelper stringValue:bg[@"color"]];
        NSInteger bgPercent = [DXPJSONHelper integerValue:bg[@"percent"] defaultValue:0];
        self.mainView.backgroundColor = [DXPPromotionColorUtils parseColor:color opacityPercent:bgPercent];
        self.mainView.layer.cornerRadius = [DXPJSONHelper integerValue:bg[@"corner"] defaultValue:12];
        self.mainView.clipsToBounds = YES;
    }
    NSDictionary *backdrop = p.appFrameBackdrop;
    NSString *backdropColor = [DXPJSONHelper stringValue:backdrop[@"color"]];
    NSInteger backdropPercent = [DXPJSONHelper integerValue:backdrop[@"percent"] defaultValue:0];
    self.rootView.backgroundColor = [DXPPromotionColorUtils parseColor:backdropColor opacityPercent:backdropPercent];

    if ([DXPJSONHelper string:p.appFramePosition equals:@"bottom"]) {
        [self.mainView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.rootView).offset(24);
            make.trailing.mas_equalTo(self.rootView).offset(-24);
            make.bottom.mas_equalTo(self.rootView).offset(-24);
        }];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat containerWidth = CGRectGetWidth(self.mainView.bounds);
    if (self.mediaImageView.image && containerWidth > 0
        && fabs(containerWidth - self.mediaLayoutContainerWidth) > 1.0) {
        [self updateMediaImageLayoutWithImage:self.mediaImageView.image extraTop:[self mediaImageExtraTopInset]];
    }
    DXPPopupModel *p = [self popup];
    [self applyBorderStyle:p.primaryButtonBorderStyle toButton:self.primaryButton cornerRadius:p.primaryButtonCorner];
    [self applyBorderStyle:p.secondaryButtonBorderStyle toButton:self.secondaryButton cornerRadius:p.secondaryButtonCorner];
}

static NSString * const kDXPPopupButtonBorderLayerName = @"dxp.promotion.button.border";

/// borderStyle 默认无边框；line 为 solid/dashed，width/color 控制线宽与颜色
- (void)applyBorderStyle:(NSDictionary *)borderStyle toButton:(UIButton *)button cornerRadius:(CGFloat)cornerRadius {
    for (CALayer *layer in [button.layer.sublayers copy]) {
        if ([layer.name isEqualToString:kDXPPopupButtonBorderLayerName]) {
            [layer removeFromSuperlayer];
        }
    }
    button.layer.borderWidth = 0;
    button.layer.borderColor = nil;

    if (!borderStyle) {
        return;
    }
    NSString *line = [[DXPJSONHelper stringValue:borderStyle[@"line"]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger width = [DXPJSONHelper integerValue:borderStyle[@"width"] defaultValue:0];
    if ([DXPJSONHelper isEmptyString:line] || width <= 0) {
        return;
    }

    UIColor *borderColor = [DXPPromotionColorUtils parseColor:[DXPJSONHelper stringValue:borderStyle[@"color"]]];
    if (!borderColor) {
        return;
    }

    button.layer.cornerRadius = cornerRadius;
    CGRect bounds = button.bounds;
    if (CGRectIsEmpty(bounds)) {
        return;
    }

    if ([DXPJSONHelper string:line equals:@"solid"]) {
        button.layer.borderWidth = (CGFloat)width;
        button.layer.borderColor = borderColor.CGColor;
        return;
    }

    if ([DXPJSONHelper string:line equals:@"dashed"]) {
        CGFloat inset = (CGFloat)width / 2.0;
        CGRect strokeRect = CGRectInset(bounds, inset, inset);
        CGFloat radius = MAX(cornerRadius - inset, 0);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:strokeRect cornerRadius:radius];
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.name = kDXPPopupButtonBorderLayerName;
        borderLayer.frame = bounds;
        borderLayer.path = path.CGPath;
        borderLayer.fillColor = UIColor.clearColor.CGColor;
        borderLayer.strokeColor = borderColor.CGColor;
        borderLayer.lineWidth = (CGFloat)width;
        borderLayer.lineDashPattern = @[@(width * 2), @(width)];
        [button.layer addSublayer:borderLayer];
    }
}

/// 媒体区域顶部额外内边距（来自 mediaPaddingStyle.top）
- (CGFloat)mediaImageExtraTopInset {
    NSDictionary *padding = [self popup].mediaPaddingStyle;
    if (!padding) return 0;
    return (CGFloat)[DXPJSONHelper integerValue:padding[@"top"] defaultValue:0];
}

/// 媒体图水平方向总边距（padding left + right，用于计算展示宽度）
- (CGFloat)mediaImageHorizontalMarginTotal {
    return [self mediaImageLeadingInset] + [self mediaImageTrailingInset];
}

/// 媒体图左右内边距（仅 padding，不含额外固定 inset，以撑满弹框可用宽度）
- (CGFloat)mediaImageLeadingInset {
    NSDictionary *padding = [self popup].mediaPaddingStyle;
    return padding ? (CGFloat)[DXPJSONHelper integerValue:padding[@"left"] defaultValue:0] : 0;
}

- (CGFloat)mediaImageTrailingInset {
    NSDictionary *padding = [self popup].mediaPaddingStyle;
    return padding ? (CGFloat)[DXPJSONHelper integerValue:padding[@"right"] defaultValue:0] : 0;
}

/// 按图片比例更新 mediaImageView：宽度撑满 mainView（减 padding），高度按比例；倒计时浮层右上角不占位
- (void)updateMediaImageLayoutWithImage:(UIImage *)image extraTop:(CGFloat)extraTop {
    CGFloat containerWidth = CGRectGetWidth(self.mainView.bounds);
    if (containerWidth <= 0 || !image || image.size.width <= 0) {
        return;
    }

    CGSize size = [DXPPromotionImageLayoutHelper displaySizeForImage:image
                                                       containerSize:CGSizeMake(containerWidth, CGRectGetHeight(UIScreen.mainScreen.bounds))
                                                horizontalMarginTotal:[self mediaImageHorizontalMarginTotal]
                                                      maxHeightRatio:kDXPPopupMediaMaxHeightRatio];
    if (size.width <= 0 || size.height <= 0) {
        return;
    }

    self.mediaLayoutContainerWidth = containerWidth;
    CGFloat leading = [self mediaImageLeadingInset];
    CGFloat trailing = [self mediaImageTrailingInset];

    self.mediaImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mediaImageView.clipsToBounds = YES;

    [self.mediaImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainView).offset(extraTop);
        make.leading.mas_equalTo(self.mainView).offset(leading);
        make.trailing.mas_equalTo(self.mainView).offset(-trailing);
        make.height.mas_equalTo(size.height);
    }];
}

/// 加载媒体图（video 类型暂不处理）；完成后重新计算布局
- (void)refreshImage {
    DXPPopupModel *p = [self popup];
    if ([DXPJSONHelper string:p.mediaType equals:@"video"]) {
        return;
    }
    CGFloat extraTop = [self mediaImageExtraTopInset];
    __weak typeof(self) weakSelf = self;
    [self.mediaImageView sd_setImageWithURL:[NSURL URLWithString:p.mediaURL ?: @""]
                           placeholderImage:nil
                                    options:SDWebImageRetryFailed
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !image) return;
        self.mediaLayoutContainerWidth = 0;
        [self updateMediaImageLayoutWithImage:image extraTop:extraTop];
    }];
}

- (UIFont *)fontWithStyle:(NSDictionary *)fontStyle defaultSize:(NSInteger)defaultSize {
    NSInteger size = [DXPJSONHelper integerValue:fontStyle[@"size"] defaultValue:defaultSize];
    BOOL bold = [DXPJSONHelper boolValue:fontStyle[@"bold"] defaultValue:NO];
    BOOL italic = [DXPJSONHelper boolValue:fontStyle[@"italic"] defaultValue:NO];
    UIFont *font = [UIFont systemFontOfSize:size];
    if (bold || italic) {
        UIFontDescriptorSymbolicTraits traits = 0;
        if (bold) traits |= UIFontDescriptorTraitBold;
        if (italic) traits |= UIFontDescriptorTraitItalic;
        UIFontDescriptor *descriptor = [[font fontDescriptor] fontDescriptorWithSymbolicTraits:traits];
        if (descriptor) {
            font = [UIFont fontWithDescriptor:descriptor size:size];
        } else if (bold) {
            font = [UIFont boldSystemFontOfSize:size];
        } else if (italic) {
            font = [UIFont italicSystemFontOfSize:size];
        }
    }
    return font;
}

/// 根据 fontStyle 生成富文本（size / color / bold / italic / underline）
- (NSAttributedString *)attributedForTitleContent:(NSString *)content fontStyle:(NSDictionary *)fontStyle {
    if ([DXPJSONHelper isEmptyString:content]) return [[NSAttributedString alloc] initWithString:@""];
    NSDictionary *style = fontStyle ?: @{};
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:content];
    NSRange range = NSMakeRange(0, content.length);
    UIFont *font = [self fontWithStyle:style defaultSize:16];
    [s addAttribute:NSFontAttributeName value:font range:range];
    UIColor *color = [DXPPromotionColorUtils parseColor:[DXPJSONHelper stringValue:style[@"color"]]];
    if (color) {
        [s addAttribute:NSForegroundColorAttributeName value:color range:range];
    }
    if ([DXPJSONHelper boolValue:style[@"underline"] defaultValue:NO]) {
        [s addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    }
    return s;
}

- (BOOL)isButtonArrangementInline {
    return [DXPJSONHelper string:[[self popup] buttonArrangement] equals:@"inline"];
}

- (void)applyButtonMinWidth:(NSInteger)minWidth toConstraints:(MASConstraintMaker *)make {
    if (minWidth > 0) {
        make.width.mas_greaterThanOrEqualTo(minWidth);
    }
}

/// 单按钮水平约束（非 fullWidth）
- (void)applyHorizontalButtonLayout:(NSString *)layout
                               make:(MASConstraintMaker *)make
                           minWidth:(NSInteger)minWidth {
    if ([DXPJSONHelper string:layout equals:@"autoLeft"]) {
        make.leading.mas_equalTo(self.mainView).offset(kDXPPopupContentHorizontalInset);
    } else if ([DXPJSONHelper string:layout equals:@"autoRight"]) {
        make.trailing.mas_equalTo(self.mainView).offset(-kDXPPopupContentHorizontalInset);
    } else {
        make.centerX.mas_equalTo(self.mainView);
    }
    [self applyButtonMinWidth:minWidth toConstraints:make];
}

/// 按 button.layout + arrangement 更新主/副按钮约束
- (void)refreshButtonLayout {
    DXPPopupModel *p = [self popup];
    NSString *buttonLayout = p.buttonLayout;
    BOOL inlineLayout = [self isButtonArrangementInline];
    BOOL showPrimary = !self.primaryButton.hidden;
    BOOL showSecondary = !self.secondaryButton.hidden;
    BOOL showAnyButton = showPrimary || showSecondary;
    BOOL fullWidth = [DXPJSONHelper string:buttonLayout equals:@"fullWidth"];
    NSInteger minWidth = p.buttonMinWidth;

    MASViewAttribute *buttonTopAnchor = self.subsTitleLabel.mas_bottom;
    CGFloat buttonTopOffset = showAnyButton ? kDXPPopupButtonInterSpacing : 0;
    CGFloat padding = kDXPPopupContentHorizontalInset;
    CGFloat gap = kDXPPopupButtonInterSpacing;

    [self.secondaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(showSecondary ? kDXPPopupButtonHeight : 0);
        if (!showSecondary) {
            return;
        }
    }];

    [self.primaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(showPrimary ? kDXPPopupButtonHeight : 0);
        if (!showPrimary) {
            return;
        }
    }];

    if (!showAnyButton) {
        [self.subsTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mainView).offset(-padding);
        }];
        return;
    }

    [self.subsTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_lessThanOrEqualTo(self.mainView);
    }];

    // 仅一个按钮
    if (showPrimary ^ showSecondary) {
        UIButton *button = showPrimary ? self.primaryButton : self.secondaryButton;
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(buttonTopAnchor).offset(buttonTopOffset);
            make.height.mas_equalTo(kDXPPopupButtonHeight);
            make.bottom.mas_equalTo(self.mainView).offset(-padding);
            if (fullWidth) {
                make.leading.mas_equalTo(self.mainView).offset(padding);
                make.trailing.mas_equalTo(self.mainView).offset(-padding);
            } else {
                [self applyHorizontalButtonLayout:buttonLayout make:make minWidth:minWidth];
            }
        }];
        return;
    }

    // 两个按钮同一行（inline）
    if (inlineLayout) {
        if (fullWidth) {
            [self.secondaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(buttonTopAnchor).offset(buttonTopOffset);
                make.leading.mas_equalTo(self.mainView).offset(padding);
                make.height.mas_equalTo(kDXPPopupButtonHeight);
                make.width.mas_equalTo(self.primaryButton);
                make.bottom.mas_equalTo(self.mainView).offset(-padding);
            }];
            [self.primaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.secondaryButton);
                make.leading.mas_equalTo(self.secondaryButton.mas_trailing).offset(gap);
                make.trailing.mas_equalTo(self.mainView).offset(-padding);
                make.height.mas_equalTo(self.secondaryButton);
                make.width.mas_equalTo(self.secondaryButton);
            }];
        } else if ([DXPJSONHelper string:buttonLayout equals:@"autoRight"]) {
            [self.primaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(buttonTopAnchor).offset(buttonTopOffset);
                make.trailing.mas_equalTo(self.mainView).offset(-padding);
                make.height.mas_equalTo(kDXPPopupButtonHeight);
                make.bottom.mas_equalTo(self.mainView).offset(-padding);
                [self applyButtonMinWidth:minWidth toConstraints:make];
            }];
            [self.secondaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.primaryButton);
                make.trailing.mas_equalTo(self.primaryButton.mas_leading).offset(-gap);
                make.height.mas_equalTo(self.primaryButton);
                make.width.mas_equalTo(self.primaryButton);
            }];
        } else if ([DXPJSONHelper string:buttonLayout equals:@"autoLeft"]) {
            [self.secondaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(buttonTopAnchor).offset(buttonTopOffset);
                make.leading.mas_equalTo(self.mainView).offset(padding);
                make.height.mas_equalTo(kDXPPopupButtonHeight);
                make.bottom.mas_equalTo(self.mainView).offset(-padding);
                [self applyButtonMinWidth:minWidth toConstraints:make];
            }];
            [self.primaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.secondaryButton);
                make.leading.mas_equalTo(self.secondaryButton.mas_trailing).offset(gap);
                make.height.mas_equalTo(self.secondaryButton);
                make.width.mas_equalTo(self.secondaryButton);
            }];
        } else {
            // autoMiddle：整组居中，副按钮在左、主按钮在右
            CGFloat centerOffset = ((CGFloat)MAX(minWidth, 0) + gap) / 2.0;
            [self.secondaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(buttonTopAnchor).offset(buttonTopOffset);
                make.centerX.mas_equalTo(self.mainView).offset(-centerOffset);
                make.height.mas_equalTo(kDXPPopupButtonHeight);
                make.bottom.mas_equalTo(self.mainView).offset(-padding);
                [self applyButtonMinWidth:minWidth toConstraints:make];
            }];
            [self.primaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.secondaryButton);
                make.leading.mas_equalTo(self.secondaryButton.mas_trailing).offset(gap);
                make.height.mas_equalTo(self.secondaryButton);
                make.width.mas_equalTo(self.secondaryButton);
            }];
        }
        return;
    }

    // 两个按钮纵向排列
    [self.primaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(buttonTopAnchor).offset(buttonTopOffset);
        make.height.mas_equalTo(kDXPPopupButtonHeight);
        if (fullWidth) {
            make.leading.mas_equalTo(self.mainView).offset(padding);
            make.trailing.mas_equalTo(self.mainView).offset(-padding);
        } else {
            [self applyHorizontalButtonLayout:buttonLayout make:make minWidth:minWidth];
        }
        if (!showSecondary) {
            make.bottom.mas_equalTo(self.mainView).offset(-padding);
        }
    }];

    [self.secondaryButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.primaryButton.mas_bottom).offset(gap);
        make.height.mas_equalTo(kDXPPopupButtonHeight);
        make.bottom.mas_equalTo(self.mainView).offset(-padding);
        if (fullWidth) {
            make.leading.trailing.mas_equalTo(self.primaryButton);
        } else {
            [self applyHorizontalButtonLayout:buttonLayout make:make minWidth:minWidth];
        }
    }];
}

- (void)refreshTitle {
    DXPPopupModel *p = [self popup];
    NSString *content = p.titleContent;
    self.mainTitleLabel.attributedText = [self attributedForTitleContent:content fontStyle:p.titleStyle];
    self.mainTitleLabel.hidden = [DXPJSONHelper isEmptyString:content];
}

- (void)refreshContent {
    DXPPopupModel *p = [self popup];
    NSString *content = p.messageContent;
    self.subsTitleLabel.attributedText = [self attributedForTitleContent:content fontStyle:p.messageStyle];
    self.subsTitleLabel.hidden = [DXPJSONHelper isEmptyString:content];
}

- (void)refreshPrimaryButton {
    DXPPopupModel *p = [self popup];
    NSString *content = p.primaryButtonText;
    [self.primaryButton setAttributedTitle:[self attributedForTitleContent:content fontStyle:p.primaryButtonFontStyle] forState:UIControlStateNormal];
    self.primaryButton.backgroundColor = [DXPPromotionColorUtils parseColor:p.primaryButtonFilledColor];
    self.primaryButton.layer.cornerRadius = p.primaryButtonCorner;
    self.primaryButton.hidden = [DXPJSONHelper isEmptyString:content];
    [self applyBorderStyle:p.primaryButtonBorderStyle toButton:self.primaryButton cornerRadius:p.primaryButtonCorner];
    [self refreshButtonLayout];
}

- (void)refreshSecondaryButton {
    DXPPopupModel *p = [self popup];
    NSString *content = p.secondaryButtonText;
    [self.secondaryButton setAttributedTitle:[self attributedForTitleContent:content fontStyle:p.secondaryButtonFontStyle] forState:UIControlStateNormal];
    self.secondaryButton.backgroundColor = [DXPPromotionColorUtils parseColor:p.secondaryButtonFilledColor];
    self.secondaryButton.layer.cornerRadius = p.secondaryButtonCorner;
    self.secondaryButton.hidden = [DXPJSONHelper isEmptyString:content];
    [self applyBorderStyle:p.secondaryButtonBorderStyle toButton:self.secondaryButton cornerRadius:p.secondaryButtonCorner];
    [self refreshButtonLayout];
}

/// filled 样式：圆形背景 + X 区域镂空（透明）
- (UIImage *)closeButtonFilledImageWithColor:(UIColor *)color size:(CGFloat)size {
    if (!color || size <= 0) {
        return nil;
    }
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize canvasSize = CGSizeMake(size, size);
    UIGraphicsBeginImageContextWithOptions(canvasSize, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, size, size);

    UIBezierPath *circle = [UIBezierPath bezierPathWithOvalInRect:rect];
    [color setFill];
    [circle fill];

    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGFloat inset = size * 0.32;
    CGFloat lineWidth = MAX(size * 0.09, 1.5);
    UIBezierPath *xPath = [UIBezierPath bezierPath];
    [xPath moveToPoint:CGPointMake(inset, inset)];
    [xPath addLineToPoint:CGPointMake(size - inset, size - inset)];
    [xPath moveToPoint:CGPointMake(size - inset, inset)];
    [xPath addLineToPoint:CGPointMake(inset, size - inset)];
    xPath.lineWidth = lineWidth;
    xPath.lineCapStyle = kCGLineCapRound;
    [xPath stroke];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/// 关闭按钮：enabled 显隐；style.type 为 line/filled；color/size 控制外观；closeOnBackdrop 遮罩关闭
- (void)refreshDismissal {
    DXPPopupModel *p = [self popup];
    BOOL countDownActive = p.countDownEnabled && p.countDownSeconds > 0;
    self.closeButton.hidden = countDownActive || !p.closeButtonEnabled;

    CGFloat closeSize = (CGFloat)p.closeButtonSize;
    if (closeSize <= 0) {
        closeSize = kDXPPopupCloseButtonDefaultSize;
    }
    UIColor *closeColor = [DXPPromotionColorUtils parseColor:p.closeButtonColor];
    BOOL isFilledStyle = [DXPJSONHelper string:p.closeButtonStyleType equals:@"filled"];

    self.closeButton.backgroundColor = UIColor.clearColor;
    self.closeButton.layer.cornerRadius = 0;
    self.closeButton.clipsToBounds = NO;
    [self.closeButton setImage:nil forState:UIControlStateNormal];

    if (isFilledStyle) {
        [self.closeButton setTitle:nil forState:UIControlStateNormal];
        UIImage *filledImage = [self closeButtonFilledImageWithColor:closeColor size:closeSize];
        [self.closeButton setImage:filledImage forState:UIControlStateNormal];
        self.closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.closeButton.adjustsImageWhenHighlighted = NO;
    } else {
        [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
        [self.closeButton setTitleColor:closeColor ?: UIColor.blackColor forState:UIControlStateNormal];
        CGFloat fontSize = MAX(closeSize * 0.55, 14);
        self.closeButton.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
    }

    [self.closeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(closeSize);
    }];

    self.backdropTapGesture.enabled = p.closeOnBackdrop;
}

#pragma mark - UIGestureRecognizerDelegate

/// 仅响应遮罩区域点击，点击弹窗卡片 mainView 不关闭
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer != self.backdropTapGesture) {
        return YES;
    }
    CGPoint pointInMain = [touch locationInView:self.mainView];
    return ![self.mainView pointInside:pointInMain withEvent:nil];
}

- (NSString *)countDownDisplayTextForSeconds:(NSInteger)seconds {
    return [NSString stringWithFormat:@"%ld s", (long)seconds];
}

- (void)applyCountDownTimerAppearanceWithStyle:(NSDictionary *)style {
    UIColor *styleColor = [DXPPromotionColorUtils parseColor:[DXPJSONHelper stringValue:style[@"color"]]];
    CGFloat fontSize = (CGFloat)[DXPJSONHelper integerValue:style[@"size"] defaultValue:14];
    self.timerLabel.textColor = styleColor;
    self.timerLabel.font = [UIFont monospacedDigitSystemFontOfSize:fontSize weight:UIFontWeightMedium];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.timerLabel.backgroundColor = UIColor.clearColor;
    self.timerLabel.layer.cornerRadius = kDXPPopupCountDownCornerRadius;
    self.timerLabel.layer.borderWidth = kDXPPopupCountDownBorderWidth;
    self.timerLabel.layer.borderColor = styleColor.CGColor;
    self.timerLabel.layer.masksToBounds = YES;
}

- (void)clearCountDownTimerAppearance {
    self.timerLabel.layer.borderWidth = 0;
    self.timerLabel.layer.cornerRadius = 0;
    self.timerLabel.layer.borderColor = nil;
    self.timerLabel.backgroundColor = UIColor.clearColor;
}

/// 倒计时：显示 timerLabel、隐藏关闭按钮，结束后自动 dismiss
- (void)refreshTimer {
    DXPPopupModel *p = [self popup];
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
    self.timerLabel.hidden = YES;
    [self clearCountDownTimerAppearance];

    if (p.countDownEnabled && p.countDownSeconds > 0) {
        NSDictionary *style = p.countDownStyle ?: @{};
        [self applyCountDownTimerAppearanceWithStyle:style];

        self.timerLabel.hidden = NO;
        self.closeButton.hidden = YES;
        [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mainView).offset(8);
            make.trailing.mas_equalTo(self.mainView).offset(-12);
            make.height.mas_greaterThanOrEqualTo(28);
            make.width.mas_greaterThanOrEqualTo(44);
        }];
        [self.mainView bringSubviewToFront:self.timerLabel];

        __block NSInteger seconds = p.countDownSeconds;
        self.timerLabel.text = [self countDownDisplayTextForSeconds:seconds];
        __weak typeof(self) weakSelf = self;
        self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) {
                [timer invalidate];
                return;
            }
            seconds--;
            self.timerLabel.text = [self countDownDisplayTextForSeconds:seconds];
            if (seconds <= 0) {
                [timer invalidate];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

- (DXPPopUp *)popUpForCallbackWithJumpUrl:(nullable NSString *)jumpUrl {
    self.dxpPopUp.jumpUrl = jumpUrl;
    return self.dxpPopUp;
}

- (nullable NSString *)resolvedJumpLinkForMediaTap {
    DXPPopupModel *p = [self popup];
    if (![DXPJSONHelper isEmptyString:p.mediaLink]) {
        return p.mediaLink;
    }
    return self.promotionInfo.mktCreativeInfo.jumpLink;
}

#pragma mark - Actions

/// 媒体区域点击，回调 dialogDelegate 跳转/埋点
- (void)mediaTapped {
    NSLog(@"[%@] promotion is click", DXPPromotionTagPopup);
    if ([self.dialogDelegate respondsToSelector:@selector(promotionDialogDidPopClick:)]) {
        [self.dialogDelegate promotionDialogDidPopClick:[self popUpForCallbackWithJumpUrl:[self resolvedJumpLinkForMediaTap]]];
    }
}

/// 遮罩区域点击关闭
- (void)backdropTapped:(UITapGestureRecognizer *)gesture {
    [self closeTapped];
}

/// 关闭按钮点击
- (void)closeTapped {
    if ([self.dialogDelegate respondsToSelector:@selector(promotionDialogDidCloseClick:)]) {
        [self.dialogDelegate promotionDialogDidCloseClick:self.dxpPopUp];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)primaryTapped {
    NSLog(@"[%@] promotion primary button is click", DXPPromotionTagPopup);
    NSString *link = [self popup].primaryButtonLink ?: self.promotionInfo.mktCreativeInfo.jumpLink;
    if ([self.dialogDelegate respondsToSelector:@selector(promotionDialogDidPrimaryClick:)]) {
        [self.dialogDelegate promotionDialogDidPrimaryClick:[self popUpForCallbackWithJumpUrl:link]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)secondaryTapped {
    NSLog(@"[%@] promotion secondary button is click", DXPPromotionTagPopup);
    NSString *link = [self popup].secondaryButtonLink ?: self.promotionInfo.mktCreativeInfo.jumpLink;
    if ([self.dialogDelegate respondsToSelector:@selector(promotionDialogDidSecondaryClick:)]) {
        [self.dialogDelegate promotionDialogDidSecondaryClick:[self popUpForCallbackWithJumpUrl:link]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
