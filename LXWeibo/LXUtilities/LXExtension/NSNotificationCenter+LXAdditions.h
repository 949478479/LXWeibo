//
//  NSNotificationCenter+LXAdditions.h
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (LXAdditions)

///------------------------------------------------------------------------------------------------
/// @name 注册通知观察者
///------------------------------------------------------------------------------------------------

/**
*  使用 @c [NSNotificationCenter defaultCenter] 注册通知观察者.
*
*  @param observer  通知观察者.
*  @param aSelector 通知回调方法 @c SEL.
*  @param aName     通知名称.
*  @param anObject  通知发送者.
*/
+ (void)lx_addObserver:(id)observer
              selector:(SEL)aSelector
                  name:(nullable NSString *)aName
                object:(nullable id)anObject;

/**
 *  使用 @c [NSNotificationCenter defaultCenter] 注册通知观察者.回调 @c block 在主队列执行.
 *
 *  @param name  通知名称.
 *  @param obj   通知发送者.
 *  @param block 通知回调 @c block.
 *
 *  @return 作为通知观察者的匿名对象.用于从通知中心移除通知观察者.由系统 retain 直到解除注册.
 */
+ (id <NSObject>)lx_addObserverForName:(nullable NSString *)name
                                object:(nullable id)obj
                            usingBlock:(void (^)(NSNotification *note))block;

/**
 *  使用 @c [NSNotificationCenter defaultCenter] 注册通知观察者.(block 版)
 *
 *  @param name  通知名称.
 *  @param obj   通知发送者.
 *  @param queue 通知回调 @c block 的执行队列.
 *  @param block 通知回调 @c block.
 *
 *  @return 作为通知观察者的匿名对象.用于从通知中心移除通知观察者.由系统 retain 直到解除注册.
 */
+ (id <NSObject>)lx_addObserverForName:(nullable NSString *)name
                                object:(nullable id)obj
                                 queue:(nullable NSOperationQueue *)queue
                            usingBlock:(void (^)(NSNotification *note))block;

/**
 *  使用 @c [NSNotificationCenter defaultCenter] 注册键盘弹出收回通知.
 *
 *  @param observer         通知观察者.
 *  @param aSelectorForShow @c UIKeyboardWillShowNotification 通知的回调方法 @c SEL.
 *  @param aSelectorForHide @c UIKeyboardWillHideNotification 通知的回调方法 @c SEL.
 */
+ (void)lx_addObserverForKeyboardShowAndHide:(id)observer
                             selectorForShow:(SEL)aSelectorForShow
                             selectorForHide:(SEL)aSelectorForHide;

/**
 *  使用 @c [NSNotificationCenter defaultCenter] 注册键盘 @c frame 改变的通知.
 *
 *  @param block    在主线程执行的回调 @c block.
 */
+ (id <NSObject>)lx_addObserverForKeyboardWillChangeFrameNotificationWithBlock:(void (^)(NSNotification *note))block;

///------------------------------------------------------------------------------------------------
/// @name 移除通知观察者
///------------------------------------------------------------------------------------------------

/**
 *  使用 @c [NSNotificationCenter defaultCenter] 移除通知观察者.
 *
 *  @param observer 通知观察者.
 */
+ (void)lx_removeObserver:(id)observer;

/**
 *  使用 @c [NSNotificationCenter defaultCenter] 移除通知观察者.
 *
 *  @param observer 通知观察者.
 *  @param aName    通知名称.
 *  @param anObject 通知发送者.
 */
+ (void)lx_removeObserver:(id)observer name:(nullable NSString *)aName object:(nullable id)anObject;

///------------------------------------------------------------------------------------------------
/// @name 发送通知
///------------------------------------------------------------------------------------------------

/**
 *  使用 @c [NSNotificationCenter defaultCenter] 发送通知.
 *
 *  @param aName    通知名称.
 *  @param anObject 通知发送者.
 */
+ (void)lx_postNotificationName:(NSString *)aName object:(nullable id)anObject;

/**
 *  使用 @c [NSNotificationCenter defaultCenter] 发送通知.
 *
 *  @param aName     通知名称.
 *  @param anObject  通知发送者.
 *  @param aUserInfo 额外信息字典.
 */
+ (void)lx_postNotificationName:(NSString *)aName
                         object:(nullable id)anObject
                       userInfo:(nullable NSDictionary *)aUserInfo;
@end

NS_ASSUME_NONNULL_END