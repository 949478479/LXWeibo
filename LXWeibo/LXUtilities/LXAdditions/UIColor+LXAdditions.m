//
//  UIColor+LXAdditions.m
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "UIColor+LXAdditions.h"

@implementation UIColor (LXAdditions)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 十六进制颜色

+ (instancetype)lx_colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha
{
    NSAssert(hex >= 0x000000 && hex <= 0xFFFFFF, @"传入的颜色值不正确.");

    return [UIColor colorWithRed:(CGFloat)((hex & 0xFF0000) >> 16) / 0xFF
                           green:(CGFloat)((hex & 0xFF00)    >> 8) / 0xFF
                            blue:(CGFloat) (hex & 0xFF)            / 0xFF
                           alpha:alpha];
}

+ (instancetype)lx_colorWithHex:(NSUInteger)hex
{
    return [self lx_colorWithHex:hex alpha:1];
}

+ (instancetype)lx_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }

    NSAssert([hexString rangeOfString:@"^[0-9A-Fa-f]{6}$"
                              options:NSRegularExpressionSearch].location != NSNotFound,
             @"参数 hexString 格式不正确.必须为 #FFFFFF 或 FFFFFF 这种形式.");

    NSString *redHexString   = [hexString substringToIndex:2];
    NSString *greenHexString = [hexString substringWithRange:(NSRange){2,2}];
    NSString *blueHexString  = [hexString substringFromIndex:4];

    uint red = 0, green = 0, blue = 0;

    [[NSScanner scannerWithString:redHexString]   scanHexInt:&red];
    [[NSScanner scannerWithString:greenHexString] scanHexInt:&green];
    [[NSScanner scannerWithString:blueHexString]  scanHexInt:&blue];

    return [self colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

+ (instancetype)lx_colorWithHexString:(NSString *)hexString
{
    return [self lx_colorWithHexString:hexString alpha:1];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 随机色

+ (instancetype)lx_randomColor
{
    return [self colorWithRed:arc4random_uniform(256)/255.0
                        green:arc4random_uniform(256)/255.0
                         blue:arc4random_uniform(256)/255.0
                        alpha:1];
}

@end