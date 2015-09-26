# 首页 PopoverView 的实现

![](https://github.com/949478479/LXWeibo/blob/screenshot/PopoverView.png)

如图.这里是继承自`UIView`自定义了一个`popover`.其实从`iOS 8`开始,`iPhone`设备也支持`popover`了.

前提是开启`Size Class`选项,否则连线时没有`popover presentation`的选项.下面两图分别是未开启和开启的情况:

![](https://github.com/949478479/LXWeibo/blob/screenshot/SegueWithoutSizeClass.png)
![](https://github.com/949478479/LXWeibo/blob/screenshot/SegueWithSizeClass.png)

然后可以在`prepareForSegue:sender:`方法里拿到目标控制器,设置其`popoverPresentationController`的`delegate`:

```objective-c
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    segue.destinationViewController.popoverPresentationController.delegate = self;
}
```

接着实现下面这个方法即可:

```objective-c
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}
```

下面总结下继承`UIView`自定义一个`popover`的思路.

`popover`是一个窗口大小的透明的`UIView`,子视图是一个`UIImageView`作为背景,以及作为实际内容的`contentView`,由外界提供.

弹出时,`popover`被添加到窗口上,箭头指向`view`:

```objective-c
- (void)presentFromView:(UIView *)view
{
    UIWindow *keyWinodw = LXKeyWindow();

    self.frame = keyWinodw.bounds;

    [keyWinodw addSubview:self];

    [self addSubview:self.contentView];

    // 将 view 的坐标由本地坐标系转换到窗口坐标系.
    CGRect viewFrameInKeyWinodw = [view convertRect:view.bounds toView:keyWinodw];

    // 宽度扩充 10 点,即两侧间距各 5 点.经多次试验,高度扩充 13 点,同时 _contentView 下移 2 点,效果比较好.
    self.backgroundView.bounds     = CGRectInset(self.contentView.bounds, -10, -13);
    self.backgroundView.lx_centerX = CGRectGetMidX(viewFrameInKeyWinodw);
    self.backgroundView.lx_originY = CGRectGetMaxY(viewFrameInKeyWinodw);

    self.contentView.center = CGPointMake(self.backgroundView.lx_centerX, self.backgroundView.lx_centerY + 2);
}
```

设置为窗口大小主要是为了屏蔽`popover`范围外的控件响应触摸以及方便`dismiss`自身,监听`touchesBegan:withEvent:`方法即可.

`popover`触发`touchesBegan:withEvent:`方法时,`dismiss`自身并通过代理通知外界:

```objective-c
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss]; // 仅仅是简单地从窗口移除.

    if ([self.delegate respondsToSelector:@selector(popoverViewDidDismiss:)]) {
        [self.delegate popoverViewDidDismiss:self];
    }
}
```

原生的`popover`还有一个`passthroughViews`属性,允许一些控件不被`popover`屏蔽触摸,这里也定义了一个:

```objective-c
@property (nullable, nonatomic, copy) NSArray<__kindof UIView *> *passthroughViews;
```

该特性通过重写`hitTest:withEvent:`方法实现:

```objective-c
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView *view in self.passthroughViews) {
        if (CGRectContainsPoint(view.bounds, [self convertPoint:point toView:view])) {
            return nil;
        }
    }
    return [super hitTest:point withEvent:event];
}
```

当点击`popover`时,一旦触摸点位于`passthroughViews`包含的视图范围内,此方法返回`nil`,放弃处理该触摸事件,这样响应链上被挡住的视图就有机会处理该触摸事件了.

利用这一特性,将标题按钮设置为`passthroughViews`,就可以透过`popover`点击标题按钮,而其他控件依然会被`popover`屏蔽触摸事件.
