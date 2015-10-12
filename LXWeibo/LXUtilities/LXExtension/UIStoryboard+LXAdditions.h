//
//  UIStoryboard+LXAdditions.h
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIStoryboard (LXAdditions)

/**
 *  设置主窗口的根控制器为指定的 @c storyboard 中的 @c initial 控制器.
 *
 *  @param storyboardName @c storyboard 文件名称.
 */
+ (void)lx_showInitialViewControllerWithStoryboardName:(NSString *)storyboardName;

/**
 *  实例化指定的 @c storyboard 中对应 @c identifier 的控制器.
 *
 *  @param storyboardName @c storyboard 文件名称.
 *  @param identifier     控制器的 @c identifier. 若传 @c nil, 则实例化 @c storyboard 中的 @c initial 控制器.
 *
 *  @return 实例化的控制器实例.
 */
+ (__kindof UIViewController *)lx_instantiateViewControllerWithStoryboardName:(NSString *)storyboardName
                                                                   identifier:(nullable NSString *)identifier;
@end

NS_ASSUME_NONNULL_END