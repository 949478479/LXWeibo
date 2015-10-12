//
//  NSDictionary+LXAdditions.h
//
//  Created by 从今以后 on 15/10/10.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (LXAdditions)

///------------------------------------------------------------------------------------------------
/// @name 常用方法
///------------------------------------------------------------------------------------------------

- (BOOL)lx_isEmpty;

///------------------------------------------------------------------------------------------------
/// @name 函数式便捷方法
///------------------------------------------------------------------------------------------------

- (NSArray *)lx_map:(id _Nullable (^)(id key, id obj))map;

- (instancetype)lx_filter:(BOOL (^)(id key, id obj))filter;

- (nullable id)lx_reduceWithInitial:(nullable id)initial
                            combine:(id _Nullable (^)(id _Nullable current, id key, id obj))combine;
@end

NS_ASSUME_NONNULL_END