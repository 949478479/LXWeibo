//
//  UIView+LXAdditions.h
//
//  Created by 从今以后 on 15/9/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIView (LXAdditions)

@property (nonatomic, assign) CGSize  lx_size;
@property (nonatomic, assign) CGFloat lx_width;
@property (nonatomic, assign) CGFloat lx_height;

@property (nonatomic, assign) CGPoint lx_origin;
@property (nonatomic, assign) CGFloat lx_originX;
@property (nonatomic, assign) CGFloat lx_originY;

@property (nonatomic, assign) CGFloat lx_centerX;
@property (nonatomic, assign) CGFloat lx_centerY;

/**
 *  @c self.layer.cornerRadius
 */
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
/**
 *  @c self.layer.borderWidth
 */
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
/**
 *  @c self.layer.borderColor
 */
@property (nullable, nonatomic, strong) IBInspectable UIColor *borderColor;

///------------------------------------------------------------------------------------------------
/// @name UINib 相关方法
///------------------------------------------------------------------------------------------------

/**
 *  返回 @c UINib 对象.即 @c [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil].
 */
+ (UINib *)lx_nib;

/**
 *  返回类名字符串.即 @c NSStringFromClass([self class]).
 */
+ (NSString *)lx_nibName;

/**
 *  使用和类名同名的 @c xib 文件实例化视图.
 *
 *  @see +lx_instantiateFromNibWithOwner:options:
 */
+ (instancetype)lx_instantiateFromNib;

/**
 *  使用和类名同名的 @c xib 文件实例化视图.
 */
+ (instancetype)lx_instantiateFromNibWithOwner:(nullable id)ownerOrNil
                                       options:(nullable NSDictionary *)optionsOrNil;

///------------------------------------------------------------------------------------------------
/// @name 其他
///------------------------------------------------------------------------------------------------

/**
 *  获取视图所属的视图控制器,即响应链上最近的 @c UIViewController.
 */
- (nullable __kindof UIViewController *)lx_viewController;

/**
 *  获取视图所属的导航控制器,即响应链上最近的 @c UINavigationController.
 */
- (nullable __kindof UINavigationController *)lx_navigationController;

/**
 *  获取视图所属的选项卡控制器,即响应链上最近的 @c UITabBarController.
 */
- (nullable __kindof UITabBarController *)lx_tabBarController;

/**
 *  执行晃动动画.
 */
- (void)lx_shakeAnimation;

@end

NS_ASSUME_NONNULL_END