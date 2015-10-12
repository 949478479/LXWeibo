//
//  NSFileManager+LXAdditions.h
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (LXAdditions)

/**
 *  计算文件或目录所占字节数.
 *
 *  @param path 文件路径或者目录路径.
 */
+ (uint64_t)lx_sizeOfItemAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END