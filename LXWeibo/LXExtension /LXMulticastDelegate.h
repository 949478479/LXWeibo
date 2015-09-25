//
//  LXMulticastDelegate.h
//
//  Created by 从今以后 on 15/9/25.
//  Copyright © 2015年 apple. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXMulticastDelegate : NSProxy

///------------------------------------------------------------------------------------------------
/// @name 构造器
///------------------------------------------------------------------------------------------------

/**
 *  用指定协议初始化多路代理实例.可顺手设定一个代理.多路代理持有代理对象的 @c weak 引用.
 */
- (instancetype)initWithProtocol:(Protocol *)protocol
                        delegate:(nullable id)delegate NS_DESIGNATED_INITIALIZER;

///------------------------------------------------------------------------------------------------
/// @name 添加/移除代理
///------------------------------------------------------------------------------------------------

/**
 *  为多路代理实例添加一个代理对象.多路代理持有代理对象的 @c weak 引用.
 */
- (void)addDelegate:(id)delegate;

/**
 *  从多路代理实例移除指定代理对象.
 */
- (void)removeDelegate:(id)delegate;

/**
 *  移除全部代理对象.
 */
- (void)removeAllDelegates;

@end

NS_ASSUME_NONNULL_END