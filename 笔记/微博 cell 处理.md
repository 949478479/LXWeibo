# 微博 cell 处理

![](https://github.com/949478479/LXWeibo/blob/screenshot/StatusCell.png)

该`cell`完全采用`AutoLayout`布局.相较于传统的手动计算`frame`和行高,该方法更为简洁.

#### 主要思路

1.  为了能准确计算多行`label`的高度,在`cell`的`awakeFromNib`方法中设置了`label`的`preferredMaxLayoutWidth`.
    
    如果不能确定`preferredMaxLayoutWidth`,多行`label`的高度计算就要麻烦一些了.

2.  不同微博配图数量可能不一样,也可能没有配图.为了省事,采取直接添加`9`个`UIImageView`的方案.
    
    将`9`个`UIImageView`装到一个容器`view`中,运行时根据实际的配图数量,确定行数,再修改容器`view`的高度约束即可.
    
    注意这里需要将该高度约束的优先级调低,例如`999`,否则`cell`创建出来时还来不及调整约束,将产生约束冲突.
    
    真正呈现在屏幕的`cell`在设置数据时,还需根据配图数量调整该高度约束,使之匹配行高.
    
    另外需要在`cell`的`prepareForReuse`方法中清空图片并隐藏,从而避免多余的渲染操作.

#### 行高计算

因为在这种环境下,行高一旦确定就不会变化,也不存在删除单元格的情况.

所以为了优化性能,并没有采取自动行高的方案,而是使用模板`cell`计算出行高后缓存的老方法.

微博`cell`定义了一个方法来供外界计算行高:

```objective-c
- (CGFloat)rowHeightWithStatus:(LXStatus *)status inTableView:(UITableView *)tableView
{
    // 设置多行 label 的文本内容,并根据配图数量修改容器 view 的高度约束...

    // 根据约束计算出 contentView 的高度.由于取消了分隔线,所以不用 +1 了.
    return [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}
```

在`tableView`的代理方法中提供行高数据并缓存,之后对于已有的行就可以直接提供缓存的行高了:

```objective-c
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row   = indexPath.row;
    NSUInteger count = self.rowHeightCache.count;

    // 之前就存在的行.针对滚动中触发此方法的情况.
    if (row < count) {
        id rowHeightNumber = self.rowHeightCache[row];
        if (rowHeightNumber != [NSNull null]) {   // 插入最新微博时会使用 [NSNull null] 作为行高占位.
            return [rowHeightNumber doubleValue]; // 命中缓存.
        }
    }

    // 利用模板 cell 根据约束计算行高.
    CGFloat rowHeight = [self.statusTemplateCell rowHeightWithStatus:self.statuses[indexPath.row]
                                                         inTableView:tableView];
                                                         
    // 初次加载或者加载最新微博时,新数据是插入到数组前面的.因此直接替换占位的 [NSNull null].
    if (row < count) {
        self.rowHeightCache[row] = @(rowHeight); 
    }
    // 加载更多微博时新数据是拼接在数组后面的.因此行高数据拼接在后面.
    else {
        [self.rowHeightCache addObject:@(rowHeight)]; 
    }

    return rowHeight;
}
```
