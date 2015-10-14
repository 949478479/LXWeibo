//
//  MBProgressHUD+LXAdditions.m
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

    hud.userInteractionEnabled = NO; // 这种类型的 HUD 没必要屏蔽触摸,显示的时候后面的 UI 最好也可以交互.

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

#pragma mark - 显示进度条 HUD

+ (MBProgressHUD *)lx_showProgressHUDToView:(UIView *)view text:(NSString *)text
{
    NSAssert(view, @"参数 view 为 nil.");

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];

    hud.removeFromSuperViewOnHide = YES;
    
    hud.mode = MBProgressHUDModeAnnularDeterminate;

    hud.labelText = text;

    [view addSubview:hud];

    [hud show:YES];

    return hud;
}

+ (MBProgressHUD *)lx_showProgressHUDWithText:(NSString *)text
{
    return [self lx_showProgressHUDToView:LXKeyWindow() text:text];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 隐藏 HUD

+ (void)lx_hideHUD
{
    [self hideHUDForView:LXKeyWindow() animated:YES];
}

+ (void)lx_hideHUDForView:(UIView *)view
{
    NSAssert(view, @"参数 view 为 nil.");
    
    [self hideHUDForView:view animated:YES];
}

@end