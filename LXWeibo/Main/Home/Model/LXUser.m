//
//  LXUser.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUser.h"

@implementation LXUser

- (void)setMbtype:(int)mbtype
{
    _mbtype = mbtype;

    _vip = mbtype > 2;
}

@end