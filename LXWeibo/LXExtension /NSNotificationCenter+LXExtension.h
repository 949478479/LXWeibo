//
//  NSNotificationCenter+LXExtension.h
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (LXExtension)

///------------------------------------------------------------------------------------------------
/// @name 注册观察者
///------------------------------------------------------------------------------------------------

/**
 *  使用 defaultCenter 注册通知观察者.
 */
+ (void)lx_addObserver:(id)observer
              selector:(SEL)aSelector
                  name:(nullable NSString *)aName
                object:(nullable id)anObject;

/**
 *  使用 defaultCenter 注册键盘弹出收回通知.
 *
 *  @param observer         观察者.
 *  @param aSelectorForShow 通知 UIKeyboardWillShowNotification 的回调方法的 SEL.
 *  @param aSelectorForHide 通知 UIKeyboardWillHideNotification 的回调方法的 SEL.
 */
+ (void)lx_addObserverForKeyboardShowAndHide:(id)observer
                             selectorForShow:(SEL)aSelectorForShow
                             selectorForHide:(SEL)aSelectorForHide;

///------------------------------------------------------------------------------------------------
/// @name 移除观察者
///------------------------------------------------------------------------------------------------

/**
 *  使用 defaultCenter 移除观察者.
 */
+ (void)lx_removeObserver:(id)observer;
+ (void)removeObserver:(id)observer name:(nullable NSString *)aName object:(nullable id)anObject;

@end

NS_ASSUME_NONNULL_END