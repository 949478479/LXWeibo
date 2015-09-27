# TabBar 加号按钮处理

![](https://github.com/949478479/LXWeibo/blob/screenshot/TabBarButton.png)

继承`UITabBar`,添加一个按钮上去,然后重写`layoutSubviews`方法将原生的四个按钮拉开距离:

```objective-c
- (void)layoutSubviews
{
    [super layoutSubviews];

    self.composeButton.center = CGPointMake(self.lx_width / 2, self.lx_height / 2);

    NSUInteger index  = 0;
    CGFloat itemWidth = self.lx_width / 5;

    for (UIView *item in self.subviews) {

        // 通过打印子控件可以查看到原生按钮的类名.
        if ([item isKindOfClass:NSClassFromString(@"UITabBarButton")]) {

            item.lx_width   = itemWidth;
            item.lx_originX = itemWidth * (index < 2 ? index : index + 1);

            if (++index == 4) {
                return;
            }
        }
    }
}
```

然后可以利用`KVC`将`UITabBarController`的`tabBar`换为自定义的子类.更省事的方法是直接在`IB`里设置`tabBar`为自定义子类.

为了在加号按钮被点击时通知外界,可以定义一个代理:

```objective-c
@protocol LXTabBarDelegate <UITabBarDelegate>
@optional
- (void)tabBar:(LXTabBar *)tabBar didTappedComposeButton:(UIButton *)composeButton;

@end

@interface LXTabBar : UITabBar
@property (nonatomic, weak) id<LXTabBarDelegate> delegate;
@end
```

这里的`delegate`属性会和父类的`delegate`冲突,因此还需要在`.m`文件里声明为`@dynamic delegate`.

按钮被点击时通知代理即可:

```objective-c
- (void)composeButtonDidTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(tabBar:didTappedComposeButton:)]) {
        [self.delegate tabBar:self didTappedComposeButton:sender];
    }
}
```
