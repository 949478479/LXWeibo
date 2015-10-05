//
//  NSArray+LXExtension.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/4.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "NSArray+LXExtension.h"

@implementation NSArray (LXExtension)

+ (instancetype)lx_arrayWithResourcePath:(NSString *)path
{
    NSAssert(path.length, @"参数 path 为空字符串或 nil.");

    return [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:path ofType:nil]];
}

@end