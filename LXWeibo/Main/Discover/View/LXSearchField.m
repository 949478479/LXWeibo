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
        placeholderView.placeholderLabel.text = _placeholder;
        [self addSubview:placeholderView];
        _placeholderView = placeholderView;
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
                _centerXConstraint = centerConstraint;
            }
        }
    }
}

#pragma mark - 监听输入情况

- (void)searchFieldEditingChanged:(UITextField *)sender
{
    _placeholderView.placeholderLabel.hidden = sender.hasText;
}

#pragma mark - 调整内部输入区域 frame

- (CGRect)adjustRectForBounds:(CGRect)bounds
{
    CGFloat offsetX = _placeholderView.placeholderLabel.lx_originX;
    bounds.origin.x   += offsetX;
    bounds.size.width -= offsetX;
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
    _centerXConstraint.constant = self.isFirstResponder ?
        (self.lx_width - _placeholderView.lx_width) / 2 : 0;

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

    if (!self.hasText) {
        [self animatePlaceholderView];
    }

    return returnValue;
}

@end