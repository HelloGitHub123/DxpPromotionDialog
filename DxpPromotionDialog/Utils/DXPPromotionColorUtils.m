#import "DXPPromotionColorUtils.h"
#import "DXPJSONHelper.h"

@implementation DXPPromotionColorUtils

+ (UIColor *)parseColor:(NSString *)colorString {
    return [self parseColor:colorString opacityPercent:100];
}

+ (UIColor *)parseColor:(NSString *)colorString opacityPercent:(NSInteger)percent {
    if ([DXPJSONHelper isEmptyString:colorString]) {
        return [UIColor colorWithWhite:0 alpha:0];
    }
    CGFloat alpha = MAX(0, MIN(100, percent)) / 100.0;
    return [self colorWithHexString:colorString alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hex alpha:(CGFloat)alpha {
    NSString *c = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([c hasPrefix:@"#"]) {
        c = [c substringFromIndex:1];
    }
    if (c.length == 8) {
        unsigned int a = 0, r = 0, g = 0, b = 0;
        [[NSScanner scannerWithString:[c substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&a];
        [[NSScanner scannerWithString:[c substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&r];
        [[NSScanner scannerWithString:[c substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&g];
        [[NSScanner scannerWithString:[c substringWithRange:NSMakeRange(6, 2)]] scanHexInt:&b];
        return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
    }
    if (c.length == 6) {
        unsigned int r = 0, g = 0, b = 0;
        [[NSScanner scannerWithString:[c substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
        [[NSScanner scannerWithString:[c substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
        [[NSScanner scannerWithString:[c substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];
        return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
    }
    return [UIColor blackColor];
}

@end
