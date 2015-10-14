//
//  MBProgressHUD+LXAdditions.h
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "MBProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBProgressHUD (LXAdditions)

///------------------------------------------------------------------------------------------------
/// @name 持续显示带蒙版的普通 HUD
///------------------------------------------------------------------------------------------------

/**
 *  将 HUD 添加到主窗口,持续显示.默认的转圈圈样式,有蒙版.需手动隐藏.
 *
 *  @param message 提示信息.
 *
 *  @return HUD 实例.
 */
+ (MBProgressHUD *)lx_showMessage:(nullable NSString *)message;

/**
 *  将 HUD 添加到指定视图,持续显示.默认的转圈圈样式,有蒙版.需手动隐藏.
 *
 *  @param message 提示信息.
 *  @param view    添加 HUD 的视图.
 *
 *  @return HUD 实例.
 */
+ (MBProgressHUD *)lx_showMessage:(nullable NSString *)message toView:(UIView *)view;

///------------------------------------------------------------------------------------------------
/// @name 短暂显示自定义图标的 HUD
///------------------------------------------------------------------------------------------------

/**
 *  将 HUD 添加到主窗口,短暂显示.可指定图标样式,无蒙版. 1s 后自动隐藏并从父视图移除.
 *
 *  @param text 提示信息.
 *  @param icon 图片名称.
 *  @param view 添加 HUD 的视图.
 */
+ (void)lx_show:(nullable NSString *)text icon:(NSString *)icon view:(UIView *)view;

///------------------------------------------------------------------------------------------------
/// @name 短暂显示成功/失败图标的 HUD
///------------------------------------------------------------------------------------------------

/**
 *  将 HUD 添加到主窗口,短暂显示.对勾图标样式,无蒙版. 1s 后自动隐藏并从父视图移除.
 *
 *  @param success 提示信息.
 */
+ (void)lx_showSuccess:(nullable NSString *)success;

/**
 *  将 HUD 添加到指定视图,短暂显示.对勾图标样式,无蒙版. 1s 后自动隐藏并从父视图移除.
 *
 *  @param success 提示信息.
 *  @param view  添加 HUD 的视图.
 */
+ (void)lx_showSuccess:(nullable NSString *)success toView:(UIView *)view;

/**
 *  将 HUD 添加到主窗口,短暂显示.叉叉图标样式,无蒙版. 1s 后自动隐藏并从父视图移除.
 *
 *  @param error 提示信息.
 */
+ (void)lx_showError:(nullable NSString *)error;

/**
 *  将 HUD 添加到指定视图,短暂显示.对勾图标样式,无蒙版. 1s 后自动隐藏并从父视图移除.
 *
 *  @param error 提示信息.
 *  @param view  添加 HUD 的视图.
 */
+ (void)lx_showError:(nullable NSString *)error toView:(UIView *)view;

/**
 *  将 HUD 添加到主窗口,持续显示.环形进度条样式,无蒙版.需手动设置 @c progress 属性以及手动隐藏.
 *
 *  @param text 提示信息.
 *
 *  @return HUD 实例.
 */
+ (MBProgressHUD *)lx_showProgressHUDWithText:(nullable NSString *)text;

/**
 *  将 HUD 添加到指定视图,持续显示.环形进度条样式,无蒙版.需手动设置 @c progress 属性以及手动隐藏.
 *
 *  @param view 添加 HUD 的视图.
 *  @param text 提示信息.
 *
 *  @return HUD 实例.
 */
+ (MBProgressHUD *)lx_showProgressHUDToView:(UIView *)view text:(nullable NSString *)text;

///------------------------------------------------------------------------------------------------
/// @name 隐藏 HUD
///------------------------------------------------------------------------------------------------

/**
 *  隐藏主窗口上的 HUD.
 */
+ (void)lx_hideHUD;

/**
 *  隐藏指定视图上的 HUD.
 *
 *  @param view  要隐藏 HUD 的视图.
 */
+ (void)lx_hideHUDForView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END