#import "DXPImagePromotionCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "DXPPromotionInfo.h"
#import "DXPMktCreativeInfo.h"
#import "DXPPopUp.h"
#import "DXPPromotionTags.h"
#import "DXPPromotionImageLayoutHelper.h"

static const CGFloat kDXPImageCellHorizontalInset = 24.0;
static const CGFloat kDXPImageCellMaxHeightRatio = 0.65;

@interface DXPImagePromotionCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong, nullable) DXPPromotionInfo *info;
@end

@implementation DXPImagePromotionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.contentView);
            make.width.mas_equalTo(1);
            make.height.mas_equalTo(1);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [_imageView addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.imageView.image) {
        [DXPPromotionImageLayoutHelper updateImageView:self.imageView
                                              withImage:self.imageView.image
                                          containerView:self.contentView
                                    horizontalMarginTotal:kDXPImageCellHorizontalInset * 2
                                         maxHeightRatio:kDXPImageCellMaxHeightRatio];
    }
}

- (void)configureWithInfo:(DXPPromotionInfo *)info {
    self.info = info;
    __weak typeof(self) weakSelf = self;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:info.mktCreativeInfo.thumbnail ?: @""]
                      placeholderImage:nil
                               options:SDWebImageRetryFailed
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || !image) return;
        [DXPPromotionImageLayoutHelper updateImageView:self.imageView
                                             withImage:image
                                         containerView:self.contentView
                                   horizontalMarginTotal:kDXPImageCellHorizontalInset * 2
                                        maxHeightRatio:kDXPImageCellMaxHeightRatio];
    }];
}

- (void)tapped {
    NSLog(@"[%@] promotion is click", DXPPromotionTagImageBinder);
    DXPPopUp *pop = [[DXPPopUp alloc] init];
    pop.jumpUrl = self.info.mktCreativeInfo.jumpLink;
    pop.transactionSn = self.info.transactionSn;
    if ([self.dialogDelegate respondsToSelector:@selector(promotionDialogDidPopClick:)]) {
        [self.dialogDelegate promotionDialogDidPopClick:pop];
    }
}

@end
