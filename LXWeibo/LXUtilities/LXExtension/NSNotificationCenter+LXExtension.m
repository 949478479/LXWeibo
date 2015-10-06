//
//  NSNotificationCenter+LXExtension.m
//
//  Created by 从今以后 on 15/9/17.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "NSNotificationCenter+LXExtension.h"

@implementation NSNotificationCenter (LXExtension)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 注册通知

+ (void)lx_addObserver:(id)observer
              selector:(SEL)aSelector
                  name:(nullable NSString *)aName
                object:(nullable id)anObject
{
    [[self defaultCenter] addObserver:observer
                             selector:aSelector
                                 name:aName
                               object:anObject];
}

+ (id <NSObject>)lx_addObserverForName:(nullable NSString *)name
                                object:(nullable id)obj
                            usingBlock:(void (^)(NSNotification *note))block
{
    return [self lx_addObserverForName:name
                                object:obj
                                 queue:[NSOperationQueue mainQueue]
                            usingBlock:block];
}

+ (id <NSObject>)lx_addObserverForName:(nullable NSString *)name
                                object:(nullable id)obj
                                 queue:(nullable NSOperationQueue *)queue
                            usingBlock:(void (^)(NSNotification *note))block
{
    return [[self defaultCenter] addObserverForName:name
                                             object:obj
                                              queue:queue
                                         usingBlock:block];
}

+ (void)lx_addObserverForKeyboardShowAndHide:(id)observer
                             selectorForShow:(SEL)aSelectorForShow
                             selectorForHide:(SEL)aSelectorForHide
{
    [self lx_addObserver:observer
                selector:aSelectorForShow
                    name:UIKeyboardWillShowNotification
                  object:nil];

    [self lx_addObserver:observer
                selector:aSelectorForHide
                    name:UIKeyboardWillHideNotification
                  object:nil];
}

+ (id <NSObject>)lx_addObserverForKeyboardWillChangeFrameNotificationWithBlock:(void (^)(NSNotification *note))block
{
    return [self lx_addObserverForName:UIKeyboardWillChangeFrameNotification
                                object:nil
                            usingBlock:block];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 移除通知

+ (void)lx_removeObserver:(id)observer
{
    [[self defaultCenter] removeObserver:observer];
}

+ (void)lx_removeObserver:(id)observer name:(nullable NSString *)aName object:(nullable id)anObject
{
    [[self defaultCenter] removeObserver:observer
                                    name:aName
                                  object:anObject];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 发送通知

+ (void)lx_postNotificationName:(NSString *)aName object:(nullable id)anObject
{
    [[self defaultCenter] postNotificationName:aName object:anObject];
}

+ (void)lx_postNotificationName:(NSString *)aName
                         object:(nullable id)anObject
                       userInfo:(nullable NSDictionary *)aUserInfo
{
    [[self defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

@end