# PageControl 的实现

![](https://github.com/949478479/LXWeibo/blob/screenshot/PageControl.gif)

如图.新浪微博的`page control`大概就长这样.

本来之前可以直接通过`KVC`设置`UIPageControl`的`_pageImage`和`_currentPageImage`变量,这样默认的小圆点就变成自定义的图片了.但是`iOS 9`之后头文件改了,没有暴露该变量,`KVC`也取不出来值,观察内部结构貌似就只有三个`UIView`而已.

于是只好自己试着整一个`page control`,为了好看,还加了这种穿梭效果.我感觉萌萌的...

#### 接口设计

基本上是模仿`UIPageControl`的接口.为了方便,增加了`IB`支持.

```objective-c
@interface LXPageControl : UIView

@property (nonatomic, assign) CGFloat percent;

@property (nonatomic, assign) IBInspectable BOOL hidesForSinglePage;

@property (nonatomic, assign) IBInspectable NSUInteger currentPage;
@property (nonatomic, assign) IBInspectable NSUInteger countOfPages;

@property (nullable, nonatomic, strong) IBInspectable UIColor *pagesColor;
@property (nullable, nonatomic, strong) IBInspectable UIColor *currentColor;

@end
```

#### 主要思路

设置`LXPageControl`的`backgroundColor`为`pagesColor`,然后用一条贝塞尔曲线画出对应数量的小圆角矩形,并将其设置为一个`CAShapeLayer`的`path`,再将该`CAShapeLayer`作为`LXPageControl`的`layer`的`mask`,并使之和`LXPageControl`一样大小.由于`mask`的特点,只有透过这些"小洞"才能看到背后的`LXPageControl`的颜色,而其他部分都会是透明的.接着可以用一个普通的`CALayer`作为`currentPageIndicator`,其形状和"小洞"是一样的,`backgroundColor`则是`currentColor`,将其调整到小洞的位置,就能露出来了.

核心实现如下:

```objective-c
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
```

当`countOfPages`为`1`且`hidesForSinglePage`开启时,`maskLayer`的`path`未赋值,而其本身也没有设置颜色,这样将其设置成`mask`时,整个`LXPageControl`将变为透明,达到隐藏的目的.而`countOfPages`为`0`时也不会绘制`path`,因此`LXPageControl`同样是透明的.

另外由于设置`mask`会引起离屏渲染,因此开启了`shouldRasterize`来缓存,提升一些渲染性能.

使用时,通过实时改变`percent`属性来移动`currentPageIndicator`图层的位置,让其在各个小洞之间穿梭.

由于图层的隐式动画,直接修改`currentPage`来移动`currentPageIndicator`效果也不错.

#### 其他细节

为了布局方便,提供了`intrinsicContentSize`,其高度为固定值,宽度根据`countOfPages`计算,这样只需设置位置约束就可以了:

```objective-c
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
```

当`LXPageControl`的`frame`变化时,需要调整`mask`以及`currentPageIndicator`:

```objective-c
- (void)layoutSubviews
{
    [super layoutSubviews];

    // frame 有变化时修正 currentPageIndicator 图层以及 mask 图层的位置.
    self.layer.mask.frame = self.bounds;
    self.currentPageIndicator.lx_origin = (CGPoint) {
        _currentPage * (kPageIndicatorWidth + kPageIndicatorMargin), 0
    };
}
```

当`countOfPages`变化时,需要重新绘制这些"小洞",并且由于宽度变化,需无效`intrinsicContentSize`:

```objective-c
- (void)setCountOfPages:(NSUInteger)countOfPages
{
    if (_countOfPages == countOfPages) {
        return;
    }

    _countOfPages = countOfPages;

    [self configurePageIndicator]; // 重新绘制小圆点.

    [self invalidateIntrinsicContentSize]; // 无效当前固有尺寸.
}
```

当然,修改`pagesColor`和`currentColor`时,`LXPageControl`和`currentPageIndicator`的`backgroundColor`也要随之改变.
