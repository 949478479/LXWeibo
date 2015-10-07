//
//  LXPageControl.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "LXUtilities.h"
#import "LXPageControl.h"

// 根据需要调整.
static const CGFloat kPageIndicatorMargin = 8;
static const CGFloat kPageIndicatorWidth  = 8;
static const CGFloat kPageIndicatorHeight = 4;

@interface LXPageControl ()

@property (nonatomic, strong) CALayer *currentPageIndicator;

@end

@implementation LXPageControl

#pragma mark - *** 公共方法 ***

#pragma mark - 设置指示器

- (void)setPercent:(CGFloat)percent
{
    _percent = percent;

    self.currentPageIndicator.lx_originX =
        percent * (kPageIndicatorWidth + kPageIndicatorMargin) * (self.countOfPages - 1);
}

- (void)setCountOfPages:(NSInteger)countOfPages
{
    if (_countOfPages == countOfPages) {
        return;
    }

    _countOfPages = countOfPages;

    [self configurePageIndicator]; // 重新绘制小圆点.

    [self invalidateIntrinsicContentSize]; // 无效当前固有尺寸,重新布局.
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    if (_currentPage == currentPage) {
        return;
    }

    _currentPage = currentPage;

    self.currentPageIndicator.lx_originX = currentPage * (kPageIndicatorWidth + kPageIndicatorMargin);
}

#pragma mark - 设置颜色

- (void)setCurrentColor:(UIColor *)currentColor
{
    _currentColor = currentColor;

    self.currentPageIndicator.backgroundColor = currentColor.CGColor;
}

- (void)setPagesColor:(UIColor *)pagesColor
{
    _pagesColor = pagesColor;

    self.backgroundColor = pagesColor;
}

#pragma mark - *** 私有方法 *** 

#pragma mark - 配置指示器

- (CALayer *)currentPageIndicator
{
    if (!_currentPageIndicator) {
        _currentPageIndicator = [CALayer layer];
        _currentPageIndicator.lx_size = CGSizeMake(kPageIndicatorWidth, kPageIndicatorHeight);
        _currentPageIndicator.cornerRadius = kPageIndicatorHeight / 2;
        [self.layer addSublayer:_currentPageIndicator];
    }
    return _currentPageIndicator;
}

- (void)configurePageIndicator
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    {
        // 根据绘制相应数量的椭圆形路径.为了方便计算,左右两端无间距,小圆点之间有间距.小圆点和整个控件高度相同.
        for (NSInteger i = 0; i < _countOfPages; ++i) {
            CGRect roundedRect = CGRectMake(i * (kPageIndicatorWidth + kPageIndicatorMargin),
                                            0,
                                            kPageIndicatorWidth,
                                            kPageIndicatorHeight);
            [path appendPath:[UIBezierPath bezierPathWithRoundedRect:roundedRect
                                                        cornerRadius:kPageIndicatorHeight / 2]];
        }
    }

    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    {
        maskLayer.path  = path.CGPath;
        maskLayer.frame = self.layer.bounds;
    }

    self.layer.mask = maskLayer;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = LXScreenScale();
}

#pragma mark - 布局

- (void)layoutSubviews
{
    [super layoutSubviews];

    // frame 有变化时修正 currentPageIndicator 图层以及 mask 图层的位置.
    self.layer.mask.frame = self.bounds;
    self.currentPageIndicator.lx_origin = (CGPoint) {
        self.currentPage * (kPageIndicatorWidth + kPageIndicatorMargin), 0
    };
}

- (CGSize)intrinsicContentSize
{
    // 提供固有尺寸给布局系统.
    return (CGSize) {
        self.countOfPages * kPageIndicatorWidth + (self.countOfPages - 1) * kPageIndicatorMargin,
        kPageIndicatorHeight
    };
}

@end