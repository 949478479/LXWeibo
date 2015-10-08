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
        percent * (kPageIndicatorWidth + kPageIndicatorMargin) * (_countOfPages - 1);
}

- (void)setHidesForSinglePage:(BOOL)hidesForSinglePage
{
    if (_hidesForSinglePage == hidesForSinglePage) {
        return;
    }

    _hidesForSinglePage = hidesForSinglePage;

    [self configurePageIndicator]; // 重新绘制小圆点.
}

- (void)setCountOfPages:(NSUInteger)countOfPages
{
    if (_countOfPages == countOfPages) {
        return;
    }

    _countOfPages = countOfPages;

    [self configurePageIndicator]; // 重新绘制小圆点.

    [self invalidateIntrinsicContentSize]; // 无效当前固有尺寸.
}

- (void)setCurrentPage:(NSUInteger)currentPage
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
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    {
        // countOfPages 大于 0 时才绘制小圆点.而 countOfPages == 1 且 hidesForSinglePage == YES 时不绘制.
        if (_countOfPages > 0 && !(_countOfPages == 1 && _hidesForSinglePage)) {

            CGMutablePathRef path = CGPathCreateMutable();

            CGFloat delta = kPageIndicatorWidth + kPageIndicatorMargin;
            CGFloat cornerRadius = kPageIndicatorHeight / 2;

            // 根据绘制相应数量的椭圆形路径.为了方便计算,左右两端无间距,小圆点之间有间距.小圆点和整个控件高度相同.
            for (NSUInteger i = 0; i < _countOfPages; ++i) {
                CGRect roundedRect = CGRectMake(i * delta, 0, kPageIndicatorWidth, kPageIndicatorHeight);
                CGPathAddRoundedRect(path, NULL, roundedRect, cornerRadius, cornerRadius);
            }

            maskLayer.path = path;

            CGPathRelease(path);
        }
    }

    // 无论是否绘制了小圆点都设置 mask, 否则 currentPageIndicator 会露出来.
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
        _currentPage * (kPageIndicatorWidth + kPageIndicatorMargin), 0
    };
}

- (CGSize)intrinsicContentSize
{
    if (_countOfPages == 0) {
        return CGSizeMake(0, kPageIndicatorHeight);
    }
    
    return (CGSize) {
        _countOfPages * kPageIndicatorWidth + (_countOfPages - 1) * kPageIndicatorMargin,
        kPageIndicatorHeight
    };
}

@end