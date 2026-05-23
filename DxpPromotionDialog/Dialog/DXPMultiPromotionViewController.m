#import "DXPMultiPromotionViewController.h"
#import <Masonry/Masonry.h>
#import "DXPPromotionInfo.h"
#import "DXPWebPromotionInfo.h"
#import "DXPImagePromotionCell.h"
#import "DXPWebPromotionCell.h"
#import "DXPIndicatorCell.h"
#import "DXPPopUp.h"
#import "DXPPromotionImageLayoutHelper.h"

static const CGFloat kDXPMultiPromotionHorizontalInset = 24.0;
static const CGFloat kDXPMultiPromotionMaxHeightRatio = 0.65;

static NSString * const kImageCellId = @"DXPImagePromotionCell";
static NSString * const kWebCellId = @"DXPWebPromotionCell";
static NSString * const kIndicatorCellId = @"DXPIndicatorCell";

@interface DXPMultiPromotionViewController ()
@property (nonatomic, copy) NSArray<DXPPromotionInfo *> *promotionList;
@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, strong) UICollectionView *indicatorCollectionView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation DXPMultiPromotionViewController

- (instancetype)initWithPromotionList:(NSArray<DXPPromotionInfo *> *)list {
    NSParameterAssert(list.count > 0);
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _promotionList = [list copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    UICollectionViewFlowLayout *contentLayout = [[UICollectionViewFlowLayout alloc] init];
    contentLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    contentLayout.minimumLineSpacing = 0;
    contentLayout.minimumInteritemSpacing = 0;

    self.contentCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:contentLayout];
    self.contentCollectionView.pagingEnabled = YES;
    self.contentCollectionView.showsHorizontalScrollIndicator = NO;
    self.contentCollectionView.backgroundColor = UIColor.clearColor;
    self.contentCollectionView.dataSource = self;
    self.contentCollectionView.delegate = self;
    [self.contentCollectionView registerClass:[DXPImagePromotionCell class] forCellWithReuseIdentifier:kImageCellId];
    [self.contentCollectionView registerClass:[DXPWebPromotionCell class] forCellWithReuseIdentifier:kWebCellId];

    UICollectionViewFlowLayout *indicatorLayout = [[UICollectionViewFlowLayout alloc] init];
    indicatorLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    indicatorLayout.itemSize = CGSizeMake(12, 12);
    indicatorLayout.minimumInteritemSpacing = 8;
    self.indicatorCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:indicatorLayout];
    self.indicatorCollectionView.backgroundColor = UIColor.clearColor;
    self.indicatorCollectionView.dataSource = self;
    self.indicatorCollectionView.delegate = self;
    [self.indicatorCollectionView registerClass:[DXPIndicatorCell class] forCellWithReuseIdentifier:kIndicatorCellId];

    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.contentCollectionView];
    [self.view addSubview:self.indicatorCollectionView];
    [self.view addSubview:self.closeButton];

    [self.contentCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(40);
        } else {
            make.top.mas_equalTo(self.view).offset(40);
        }
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo([self preferredContentCollectionHeight]);
    }];

    [self.indicatorCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentCollectionView.mas_bottom).offset(16);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(self.promotionList.count * 20);
    }];

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(16);
        } else {
            make.top.mas_equalTo(self.view).offset(16);
        }
        make.trailing.mas_equalTo(self.view).offset(-16);
    }];
}

- (CGFloat)preferredContentCollectionHeight {
    CGFloat height = CGRectGetHeight(self.view.bounds);
    if (height <= 0) {
        height = CGRectGetHeight(UIScreen.mainScreen.bounds);
    }
    return MAX(height * kDXPMultiPromotionMaxHeightRatio, 200);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.contentCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self preferredContentCollectionHeight]);
    }];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.contentCollectionView.collectionViewLayout;
    layout.itemSize = self.contentCollectionView.bounds.size;
}

- (void)closeTapped {
    DXPPopUp *pop = [[DXPPopUp alloc] init];
    if ([self.dialogDelegate respondsToSelector:@selector(promotionDialogDidCloseClick:)]) {
        [self.dialogDelegate promotionDialogDidCloseClick:pop];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.promotionList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.indicatorCollectionView) {
        DXPIndicatorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIndicatorCellId forIndexPath:indexPath];
        [cell setSelectedState:indexPath.item == self.currentIndex];
        return cell;
    }
    DXPPromotionInfo *info = self.promotionList[indexPath.item];
    if ([info isKindOfClass:[DXPWebPromotionInfo class]]) {
        DXPWebPromotionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWebCellId forIndexPath:indexPath];
        cell.dialogDelegate = self.dialogDelegate;
        [cell configureWithInfo:(DXPWebPromotionInfo *)info];
        return cell;
    }
    DXPImagePromotionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kImageCellId forIndexPath:indexPath];
    cell.dialogDelegate = self.dialogDelegate;
    [cell configureWithInfo:info];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.contentCollectionView) return;
    CGFloat width = scrollView.bounds.size.width;
    if (width <= 0) return;
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / width);
    if (index != self.currentIndex) {
        self.currentIndex = index;
        [self.indicatorCollectionView reloadData];
    }
}

@end
