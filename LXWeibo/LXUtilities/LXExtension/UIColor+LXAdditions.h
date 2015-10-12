//
//  UIColor+LXAdditions.h
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (LXAdditions)

///------------------------------------------------------------------------------------------------
/// @name 十六进制颜色
///------------------------------------------------------------------------------------------------

/**
 *  用十六进制的颜色值创建透明度为 @c 1 的 @c UIColor.例如,传入 @c 0xFFFFFF 将创建白色.
 */
+ (instancetype)lx_colorWithHex:(NSUInteger)hex;

/**
 *  用十六进制的颜色值创建透明度为 @c 0~1 的 @c UIColor.例如,传入 @c 0xFFFFFF 将创建白色.
 */
+ (instancetype)lx_colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha;

/**
 *  用十六进制的颜色值字符串创建透明度为 @c 1 的 @c UIColor.例如,传入 @c @"#FFFFFF" 或 @c @"FFFFFF" 将创建白色.
 */
+ (instancetype)lx_colorWithHexString:(NSString *)hexString;

/**
 *  用十六进制的颜色值字符串创建透明度为 @c 0~1 的 @c UIColor.例如,传入 @c @"#FFFFFF" 或 @c @"FFFFFF" 将创建白色.
 */
+ (instancetype)lx_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

///------------------------------------------------------------------------------------------------
/// @name 随机色
///------------------------------------------------------------------------------------------------

/**
 *  生成 @c alpha 为 @c 1 的随机色.
 */
+ (instancetype)lx_randomColor;

@end

NS_ASSUME_NONNULL_END