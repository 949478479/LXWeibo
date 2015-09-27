//
//  LXTabBar.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/24.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXTabBar.h"
#import "LXUtilities.h"

@interface LXTabBar ()

@property (nonatomic, strong) UIButton *composeButton;

@end

@implementation LXTabBar
@dynamic delegate;

#pragma mark - 初始化

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self configureComposeButton];
}

#pragma mark - 安装加号按钮

- (void)configureComposeButton
{
    self.composeButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self.composeButton.lx_normalImage      = [UIImage imageNamed:@"tabbar_compose_icon_add"];
    self.composeButton.lx_highlightedImage = [UIImage imageNamed:@"tabbar_compose_icon_add_highlighted"];

    self.composeButton.lx_normalBackgroundImage      = [UIImage imageNamed:@"tabbar_compose_button"];
    self.composeButton.lx_highlightedBackgroundImage = [UIImage imageNamed:@"tabbar_compose_button_highlighted"];

    [self.composeButton addTarget:self
                           action:@selector(composeButtonDidTapped:)
                 forControlEvents:UIControlEventTouchUpInside];

    [self.composeButton sizeToFit];

    [self addSubview:self.composeButton];
}

#pragma mark - 调整布局

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.composeButton.center = CGPointMake(self.lx_width / 2, self.lx_height / 2);

    NSUInteger index  = 0;
    CGFloat itemWidth = self.lx_width / 5;

    for (UIView *item in self.subviews) {

        if ([item isKindOfClass:NSClassFromString(@"UITabBarButton")]) {

            item.lx_width   = itemWidth;
            item.lx_originX = itemWidth * (index < 2 ? index : index + 1);

            if (++index == 4) {
                return;
            }
        }
    }
}

#pragma mark - 监听加号按钮点击

- (void)composeButtonDidTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(tabBar:didTappedComposeButton:)]) {
        [self.delegate tabBar:self didTappedComposeButton:sender];
    }
}

@end