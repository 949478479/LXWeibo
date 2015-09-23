//
//  UIColor+LXExtension.h
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

@interface UIColor (LXExtension)

/**
 *  用十六进制的颜色值创建颜色.例如,传入 0xFFFFFF 将创建白色.
 */
+ (instancetype)lx_colorWithHex:(NSUInteger)hex;

/**
 *  用十六进制的颜色值创建颜色.例如,传入 0xFFFFFF 将创建白色.
 */
+ (instancetype)lx_colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha;

/**
 *  用十六进制的颜色值字符串创建颜色.例如,传入 @"#FFFFFF" 或 @"FFFFFF" 将创建白色.
 */
+ (instancetype)lx_colorWithHexString:(NSString *)hexString;

/**
 *  用十六进制的颜色值字符串创建颜色.例如,传入 @"#FFFFFF" 或 @"FFFFFF" 将创建白色.
 */
+ (instancetype)lx_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end