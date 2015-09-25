//
//  NSObject+LXExtension.h
//
//  Created by 从今以后 on 15/9/14.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LXExtension)

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

/** 附带实例变量和值的调试信息. */
- (NSString *)lx_description;

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

@end

NS_ASSUME_NONNULL_END