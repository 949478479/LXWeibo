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
    NSAssert(observer, @"参数 observer 为 nil.");
    NSAssert(aSelector, @"参数 aSelector 为 nil.");

    [[self defaultCenter] addObserver:observer
                             selector:aSelector
                                 name:aName
                               object:anObject];
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

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 移除通知

+ (void)lx_removeObserver:(id)observer
{
    NSAssert(observer, @"参数 observer 为 nil.");

    [[self defaultCenter] removeObserver:observer];
}

+ (void)removeObserver:(id)observer name:(nullable NSString *)aName object:(nullable id)anObject
{
    NSAssert(observer, @"参数 observer 为 nil.");
    
    [[self defaultCenter] removeObserver:observer
                                    name:aName
                                  object:anObject];
}

@end