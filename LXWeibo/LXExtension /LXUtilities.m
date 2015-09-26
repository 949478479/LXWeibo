//
//  LXUtilities.m
//  LXWeChat
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@import ObjectiveC.runtime;
#import "AppDelegate.h"

#pragma clang diagnostic ignored "-Wgnu-conditional-omitted-operand"

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 沙盒路径

NSString * LXDocumentDirectory()
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

NSString * LXLibraryDirectory()
{
    return NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
}

NSString * LXCachesDirectory()
{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - AppDelegate

AppDelegate * LXAppDelegate()
{
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - 窗口

UIWindow * LXKeyWindow()
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow ?: LXAppDelegate().window;

    NSCAssert(keyWindow, @"AppDelegate 的 window 属性为 nil.");

    return keyWindow;
}

UIWindow * LXTopWindow()
{
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject ?: LXAppDelegate().window;

    NSCAssert(topWindow, @"AppDelegate 的 window 属性为 nil.");

    return topWindow;
}

UIViewController * LXTopViewController()
{
    UIViewController *rootVC = LXKeyWindow().rootViewController;
    UIViewController *topVC  = rootVC.presentedViewController;

    return topVC ?: rootVC;
}

BOOL LXDeviceIsPad()
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - runtime

void LXMethodSwizzling(Class cls, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);

    IMP originalIMP = method_getImplementation(originalMethod);
    IMP swizzledIMP = method_getImplementation(swizzledMethod);

    const char *swizzledTypes = method_getTypeEncoding(swizzledMethod);

    // 避免当前类未重写父类方法实现时覆盖掉父类的实现.
    BOOL didAddMethod = class_addMethod(cls, originalSelector, swizzledIMP, swizzledTypes);

    if (didAddMethod) {
        // 根据 class_replaceMethod 函数的说明,在此情况下应该是和 method_setImplementation 函数等效的.
        method_setImplementation(swizzledMethod, originalIMP);
    } else {
        // 若子类已经实现原始方法,class_addMethod 函数没有效果,且函数返回值为 NO ,这时候直接交换即可.
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}