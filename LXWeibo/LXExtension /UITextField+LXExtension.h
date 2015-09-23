//
//  UITextField+LXExtension.h
//
//  Created by 从今以后 on 15/9/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UITextField (LXExtension)

/**
 *  设置文本区域.即 @c -[UITextField textRectForBounds:] 方法的返回值.
 *  若未设置将沿用默认值.若只想修改部分值,例如 x 坐标,将其他值设置为负数,将会沿用默认值.(就想设置负数? >_< ...)
 *  若修改了原点坐标,但未改变宽高,宽高会在默认值基础上进行调整,不会超出范围.
 */
@property (nonatomic, assign) IBInspectable CGRect textRect;

/**
 *  设置编辑区域.即 @c -[UITextField editingRectForBounds:] 方法的返回值.
 *  若未设置将沿用默认值.若只想修改部分值,例如 x 坐标,将其他值设置为负数,将会沿用默认值.(就想设置负数? >_< ...)
 *  若修改了原点坐标,但未改变宽高,宽高会在默认值基础上进行调整,不会超出范围.
 */
@property (nonatomic, assign) IBInspectable CGRect editingRect;

/**
 *  设置左视图位置.即 @c -[UITextField leftViewRectForBounds:] 方法的返回值.
 *  若未设置将沿用默认值.若只想修改部分值,例如 x 坐标,将其他值设置为负数,将会沿用默认值.(就想设置负数? >_< ...)
 */
@property (nonatomic, assign) IBInspectable CGRect leftViewRect;

/**
 *  为 @c UITextField 添加左图标. @c UIImageView 为边长为 @c UITextField 高度的正方形,图片显示模式为居中.
 */
@property (nullable, nonatomic, strong) IBInspectable UIImage *leftViewImage;

@end

NS_ASSUME_NONNULL_END