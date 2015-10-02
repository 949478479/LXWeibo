//
//  LXSearchField.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXSearchField.h"
#import "LXPlaceholderView.h"

static const NSTimeInterval kLXAnimationDuration = 0.25;

@interface LXSearchField ()

@property (nonatomic, weak) LXPlaceholderView  *placeholderView;
@property (nonatomic, weak) NSLayoutConstraint *centerXConstraint;

@end

@implementation LXSearchField
@synthesize placeholder = _placeholder;

#pragma mark - 初始化

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self addTarget:self
             action:@selector(searchFieldEditingChanged:)
   forControlEvents:UIControlEventEditingChanged];

    [self configurePlaceholderView];
}

#pragma mark - 安装自定义的 PlaceholderView

- (void)configurePlaceholderView
{
    LXPlaceholderView *placeholderView = [LXPlaceholderView lx_instantiateFromNib];
    {
        placeholderView.placeholderLabel.text = self.placeholder;
        placeholderView.placeholderLabel.font = self.font;
        [self addSubview:placeholderView];
        self.placeholderView = placeholderView;
    }

    {
        placeholderView.translatesAutoresizingMaskIntoConstraints = NO;

        NSInteger attributes[2] = { NSLayoutAttributeCenterX, NSLayoutAttributeCenterY };
        
        for (uint i = 0; i < 2; ++i) {
            NSLayoutConstraint *centerConstraint =
                [NSLayoutConstraint constraintWithItem:self
                                             attribute:attributes[i]
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:placeholderView
                                             attribute:attributes[i]
                                            multiplier:1
                                              constant:0];
            centerConstraint.active = YES;

            if (i == 0) {
                self.centerXConstraint = centerConstraint;
            }
        }
    }
}

#pragma mark - 监听输入情况

- (void)searchFieldEditingChanged:(UITextField *)sender
{
    self.placeholderView.placeholderLabel.hidden = sender.hasText;
}

#pragma mark - 调整内部输入区域 frame

- (CGRect)adjustRectForBounds:(CGRect)bounds
{
    CGFloat offsetX = self.placeholderView.placeholderLabel.lx_originX - 1; // 往左偏 1 点效果更好看.
    bounds.origin.x   += offsetX; // 原点向右偏移到占位文字开始处.
    bounds.size.width -= offsetX; // 由于原点偏移,因此宽度需去掉偏移量,否则右侧会超出.
    return bounds;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self adjustRectForBounds:[super textRectForBounds:bounds]];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self adjustRectForBounds:[super textRectForBounds:bounds]];
}

#pragma mark - PlaceholderView 动画

- (void)animatePlaceholderView
{
    // 调整约束,让占位视图紧贴左侧或者居中.
    self.centerXConstraint.constant = self.isFirstResponder ?
        (self.lx_width - self.placeholderView.lx_width) / 2 : 0;

    [UIView animateWithDuration:kLXAnimationDuration animations:^{
        [self layoutIfNeeded];
    }];
}

- (BOOL)becomeFirstResponder
{
    BOOL returnValue = [super becomeFirstResponder];

    [self animatePlaceholderView];

    return returnValue;
}

- (BOOL)resignFirstResponder
{
    BOOL returnValue = [super resignFirstResponder];

    // 搜索框有内容时,注销响应者时不要执行动画.即让放大镜图标保持在左侧.
    if (!self.hasText) {
        [self animatePlaceholderView];
    }

    return returnValue;
}

@end