//
//  NSArray+LXExtension.h
//
//  Created by 从今以后 on 15/10/4.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (LXExtension)

/**
 *  根据相关资源在 mainBundle 中的路径创建数组.路径须带拓展名.
 */
+ (instancetype)lx_arrayWithResourcePath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END