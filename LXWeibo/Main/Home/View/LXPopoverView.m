//
//  LXPopoverView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/24.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXPopoverView.h"

@interface LXPopoverView ()

@property (nonatomic, strong) UIImageView *backgroundView;

@end

@implementation LXPopoverView

#pragma mark - 初始化

- (instancetype)initWithContentView:(UIView *)contentView
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _contentVC   = nil;
        _contentView = contentView;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _contentVC   = viewController;
        _contentView = viewController.view;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIImage *background = [UIImage imageNamed:@"popover_background"];
    _backgroundView = [[UIImageView alloc] initWithImage:background];
    _backgroundView.userInteractionEnabled = YES;

    self.backgroundColor = nil;
    [self addSubview:_backgroundView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    NSAssert(NO, @"此构造器不应该被调用.");
    UIView *view = nil; // 去除传 nil 的警告.
    return [self initWithContentView:view];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSAssert(NO, @"此构造器不应该被调用.");
    return [self initWithFrame:CGRectZero];
}

#pragma mark - 点击事件

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];

    if ([self.delegate respondsToSelector:@selector(popoverViewDidDismiss:)]) {
        [self.delegate popoverViewDidDismiss:self];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.passthroughViews) {
        if (CGRectContainsPoint(view.bounds, [self convertPoint:point toView:view])) {
            return nil;
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark - 公共方法

- (void)presentFromView:(UIView *)view
{
    UIWindow *keyWinodw = LXKeyWindow();

    self.frame = keyWinodw.bounds;

    [keyWinodw addSubview:self];

    [self addSubview:self.contentView];

    // 将 view 的坐标由本地坐标系转换到顶层窗口坐标系.
    CGRect viewFrameInKeyWinodw = [view convertRect:view.bounds toView:keyWinodw];

    // 宽度扩充 10 点,即两侧间距各 5 点.经多次试验,高度扩充 13 点,同时 _contentView 下移 2 点,效果比较好.
    self.backgroundView.bounds     = CGRectInset(self.contentView.bounds, -10, -13);
    self.backgroundView.lx_centerX = CGRectGetMidX(viewFrameInKeyWinodw);
    self.backgroundView.lx_originY = CGRectGetMaxY(viewFrameInKeyWinodw);

    self.contentView.center = CGPointMake(self.backgroundView.lx_centerX, self.backgroundView.lx_centerY + 2);
}

- (void)dismiss
{
    [self removeFromSuperview];
}

@end