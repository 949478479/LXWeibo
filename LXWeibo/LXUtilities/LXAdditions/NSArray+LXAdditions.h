//
//  NSArray+LXAdditions.h
//
//  Created by 从今以后 on 15/10/4.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (LXAdditions)

///------------------------------------------------------------------------------------------------
/// @name 常用方法
///------------------------------------------------------------------------------------------------

/**
 *  根据相关资源在 mainBundle 中的路径创建数组.路径须带拓展名.
 */
+ (nullable instancetype)lx_arrayWithResourcePath:(NSString *)path;

///------------------------------------------------------------------------------------------------
/// @name 函数式便捷方法
///------------------------------------------------------------------------------------------------

- (instancetype)lx_filter:(BOOL (^)(ObjectType obj))filter;

- (__kindof instancetype)lx_map:(id _Nullable (^)(ObjectType obj, BOOL *stop))map;

- (nullable id)lx_reduceWithInitial:(nullable id)initial
                            combine:(id _Nullable (^)(id _Nullable current, id ObjectType))combine;
@end

NS_ASSUME_NONNULL_END