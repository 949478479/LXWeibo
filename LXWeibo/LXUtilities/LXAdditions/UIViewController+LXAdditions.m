//
//  UIViewController+LXAdditions.m
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UIViewController+LXAdditions.h"

@implementation UIViewController (LXAdditions)

+ (instancetype)lx_instantiateFromNib
{
    return [[self alloc] initWithNibName:NSStringFromClass(self) bundle:nil];
}

@end