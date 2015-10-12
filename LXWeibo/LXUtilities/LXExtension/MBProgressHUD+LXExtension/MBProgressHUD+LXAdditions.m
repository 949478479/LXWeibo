//
//  MBProgressHUD+LXAdditions.m
//  LXWeChat
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "MBProgressHUD+LXAdditions.h"

@implementation MBProgressHUD (LXAdditions)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 持续显示带蒙版的普通 HUD

+ (MBProgressHUD *)lx_showMessage:(nullable NSString *)message
{
    UIWindow *keyWindow = LXKeyWindow();

    NSAssert(keyWindow, @"主窗口为 nil.");

    return [self lx_showMessage:message toView:keyWindow];
}

+ (MBProgressHUD *)lx_showMessage:(nullable NSString *)message toView:(UIView *)view
{
    NSAssert(view, @"参数 view 为 nil.");

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];

    hud.labelText = message;

    hud.dimBackground = YES;

    hud.removeFromSuperViewOnHide = YES;

    [view addSubview:hud];

    [hud show:YES];

    return hud;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 短暂显示自定义图标的 HUD

+ (void)lx_show:(nullable NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    NSAssert(view, @"参数 view 为 nil.");
    NSAssert(icon.length, @"参数 icon 为 nil 或空字符串.");

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];

    hud.labelText = text;

    hud.removeFromSuperViewOnHide = YES;

    hud.mode = MBProgressHUDModeCustomView;

    UIImage *image = [UIImage imageNamed:icon];

    NSAssert(image, @"图片不存在 => %@", icon);

    hud.customView = [[UIImageView alloc] initWithImage:image];

    [view addSubview:hud];

    [hud show:YES];

    [hud hide:YES afterDelay:1];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 短暂显示成功/失败图标的 HUD

+ (void)lx_showSuccess:(nullable NSString *)success
{
    UIWindow *keyWindow = LXKeyWindow();

    NSAssert(keyWindow, @"主窗口为 nil.");

    [self lx_showSuccess:success toView:keyWindow];
}

+ (void)lx_showSuccess:(nullable NSString *)success toView:(UIView *)view
{
    NSAssert(view, @"参数 view 为 nil.");

    [self lx_show:success icon:@"MBProgressHUD.bundle/success.png" view:view];
}

+ (void)lx_showError:(nullable NSString *)error
{
    UIWindow *keyWindow = LXKeyWindow();

    NSAssert(keyWindow, @"主窗口为 nil.");

    [self lx_showError:error toView:keyWindow];
}

+ (void)lx_showError:(nullable NSString *)error toView:(UIView *)view
{
    NSAssert(view, @"参数 view 为 nil.");

    [self lx_show:error icon:@"MBProgressHUD.bundle/error.png" view:view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 隐藏 HUD

+ (void)lx_hideHUD
{
    UIWindow *keyWindow = LXKeyWindow();

    NSAssert(keyWindow, @"主窗口为 nil.");

    [self hideHUDForView:keyWindow animated:YES];
}

+ (void)lx_hideHUDForView:(UIView *)view
{
    NSAssert(view, @"参数 view 为 nil.");
    
    [self hideHUDForView:view animated:YES];
}

@end