//
//  NSUserDefaults+LXAdditions.m
//
//  Created by 从今以后 on 15/9/27.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "NSUserDefaults+LXAdditions.h"

@implementation NSUserDefaults (LXAdditions)

#pragma mark - 同步

+ (BOOL)lx_synchronize
{
    return [[self standardUserDefaults] synchronize];
}

#pragma mark - 写入

+ (void)lx_setObject:(nullable id)value forKey:(NSString *)defaultName
{
    [[self standardUserDefaults] setObject:value forKey:defaultName];
}

#pragma mark - 读取

+ (nullable NSString *)lx_stringForKey:(NSString *)defaultName
{
    return [[self standardUserDefaults] stringForKey:defaultName];
}


@end