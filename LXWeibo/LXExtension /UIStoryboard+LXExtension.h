//
//  UIStoryboard+LXExtension.h
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIStoryboard (LXExtension)

/**
 *  设置主窗口的根控制器为指定的 storyboard 中的 initial 控制器.
 *
 *  @param storyboardName storyboard 文件名称.
 */
+ (void)lx_showInitialVCWithStoryboardName:(NSString *)storyboardName;

/**
 *  实例化指定的 storyboard 中对应 identifier 的控制器.
 *
 *  @param storyboardName storyboard 文件名称.
 *  @param identifier     控制器的 identifier. 若传 nil, 则实例化 storyboard 中的 initial 控制器.
 *
 *  @return 实例化的控制器实例.
 */
+ (__kindof UIViewController *)lx_instantiateInitialVCWithStoryboardName:(NSString *)storyboardName
                                                              identifier:(nullable NSString *)identifier;
@end

NS_ASSUME_NONNULL_END