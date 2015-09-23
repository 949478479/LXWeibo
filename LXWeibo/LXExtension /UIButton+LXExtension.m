//
//  UIButton+LXExtension.m
//
//  Created by 从今以后 on 15/9/21.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "UIButton+LXExtension.h"

@implementation UIButton (LXExtension)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 设置/获取按钮标题

- (void)setLx_normalTitle:(NSString *)lx_normalTitle
{
    [self setTitle:lx_normalTitle forState:UIControlStateNormal];
}

- (NSString *)lx_normalTitle
{
    return [self titleForState:UIControlStateNormal];
}

- (void)setLx_highlightedTitle:(NSString *)lx_highlightedTitle
{
    [self setTitle:lx_highlightedTitle forState:UIControlStateHighlighted];
}

- (NSString *)lx_highlightedTitle
{
    return [self titleForState:UIControlStateHighlighted];
}

- (void)setLx_selectedTitle:(NSString *)lx_selectedTitle
{
    [self setTitle:lx_selectedTitle forState:UIControlStateSelected];
}

- (NSString *)lx_selectedTitle
{
    return [self titleForState:UIControlStateSelected];
}

- (void)setLx_disabledTitle:(NSString *)lx_disabledTitle
{
    [self setTitle:lx_disabledTitle forState:UIControlStateDisabled];
}

- (NSString *)lx_disabledTitle
{
    return [self titleForState:UIControlStateDisabled];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

@end