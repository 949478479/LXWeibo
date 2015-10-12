//
//  NSFileManager+LXAdditions.m
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "NSFileManager+LXAdditions.h"

@implementation NSFileManager (LXAdditions)

+ (uint64_t)lx_sizeOfItemAtPath:(NSString *)path
{
    NSAssert(path, @"参数 path 不能为 nil.");

    NSFileManager *fileManager   = [self defaultManager];
    NSDictionary *itemAttributes = [fileManager attributesOfItemAtPath:path error:NULL];

    uint64_t size = 0;

    if (itemAttributes[NSFileType] == NSFileTypeDirectory) { // 文件夹.

        NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];

        while (enumerator.nextObject) {
            itemAttributes = enumerator.fileAttributes;
            if (itemAttributes[NSFileType] == NSFileTypeRegular) { // 只统计文件.
                size += [itemAttributes[NSFileSize] unsignedLongLongValue];
            }
        }

    } else { // 文件.
        size = [itemAttributes[NSFileSize] unsignedLongLongValue];
    }

    return size;
}

@end