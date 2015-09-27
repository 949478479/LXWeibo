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
 *  用指定协议初始化多路代理实例.可顺手添加一个代理成员.代理成员必须符合协议.多路代理持有代理成员的 @c weak 引用.
 */
- (instancetype)initWithProtocol:(Protocol *)protocol
                        delegate:(nullable id)delegate NS_DESIGNATED_INITIALIZER;

///------------------------------------------------------------------------------------------------
/// @name 添加/移除代理成员
///------------------------------------------------------------------------------------------------

/**
 *  为多路代理实例添加一个代理成员.代理成员必须符合协议.多路代理持有代理成员的 @c weak 引用.
 */
- (void)addDelegate:(id)delegate;

/**
 *  从多路代理实例移除指定代理成员.
 */
- (void)removeDelegate:(id)delegate;

/**
 *  移除全部代理成员.
 */
- (void)removeAllDelegates;

@end

NS_ASSUME_NONNULL_END