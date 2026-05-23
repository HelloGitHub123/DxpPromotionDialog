#import "DXPIndicatorCell.h"
#import <Masonry/Masonry.h>

@implementation DXPIndicatorCell {
    UIView *_dot;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _dot = [[UIView alloc] init];
        _dot.layer.cornerRadius = 4;
        _dot.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_dot];
        [_dot mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.contentView);
            make.width.height.mas_equalTo(8);
        }];
    }
    return self;
}

- (void)setSelectedState:(BOOL)selected {
    _dot.backgroundColor = selected ? [UIColor whiteColor] : [UIColor lightGrayColor];
}

@end
