//
//  NSObject+LXAdditions.h
//
//  Created by 从今以后 on 15/9/14.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/** @c NSObject 的直接子类采纳此协议将会覆盖 @c [NSObject description] 方法,在默认实现上附带实例变量名和值. */
@protocol LXDescription <NSObject>
@end

@interface NSObject (LXAdditions)

///------------------------------------------------------------------------------------------------
/// @name 打印调试
///------------------------------------------------------------------------------------------------

/** 打印查看实例变量. */
+ (void)lx_printIvars;
/** 打印查看实例变量. */
- (void)lx_printIvars;

/** 打印查看实例属性. */
+ (void)lx_printProperties;
/** 打印查看实例属性. */
- (void)lx_printProperties;

/** 打印查看类/实例方法. */
+ (void)lx_printMethods;
/** 打印查看类/实例方法. */
- (void)lx_printMethods;

///------------------------------------------------------------------------------------------------
/// @name 获取属性和实例变量名数组
///------------------------------------------------------------------------------------------------

/**
 *  获取属性数组.
 *
 *  @return 属性名的字符串组成的数组.
 */
+ (NSArray<NSString *> *)lx_properties;
/**
 *  获取属性数组.
 *
 *  @return 属性名的字符串组成的数组.
 */
- (NSArray<NSString *> *)lx_properties;

/**
 *  获取实例变量数组.
 *
 *  @return 实例变量名的字符串组成的数组.
 */
+ (NSArray<NSString *> *)lx_variables;
/**
 *  获取实例变量数组.
 *
 *  @return 实例变量名的字符串组成的数组.
 */
- (NSArray<NSString *> *)lx_variables;

///------------------------------------------------------------------------------------------------
/// @name 关联对象
///------------------------------------------------------------------------------------------------

/**
 *  使用 @c objc_setAssociatedObject 函数根据指定 @c key 关联对象.
 *
 *  @param value 关联的对象.
 *  @param key   关联对象对应的 @c key.
 */
- (void)lx_setValue:(nullable id)value forKey:(NSString *)key;

/**
 *  使用 @c objc_getAssociatedObject 函数获取 @c key 对应的关联对象.
 *
 *  @param key 关联对象的 @c key.
 *
 *  @return @c key 对应的关联对象.
 */
- (nullable id)lx_valueForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END