//
//  LXStatusTextView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/10.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXStatusTextLink.h"
#import "LXStatusTextView.h"

static const NSInteger kLinkBackgroundTag = 233;

@interface LXStatusTextView ()
@property (nonatomic, strong) LXStatusTextLink *touchedLink;
@property (nonatomic, copy) NSArray<LXStatusTextLink *> *links;
@end

@implementation LXStatusTextView

#pragma mark - 加载 LXStatusTextLink 数组

- (NSArray<LXStatusTextLink *> *)links
{
    if (!_links) {
        self.selectable = YES; // 允许选中,否则设置 selectedRange 无效.

        // 取出之前绑定的数组.
        NSArray *links = [self.attributedText attribute:@"links" atIndex:0 effectiveRange:NULL];

        for (LXStatusTextLink *link in links) {

            self.selectedRange = link.range; // 为了让 selectedTextRange 对应 link.range .
            NSArray *selectionRects = [self selectionRectsForRange:self.selectedTextRange];

            // 找出该字段在 textView 上的所有 rect, 赋值给 LXStatusTextLink 的 rects 属性.
            NSMutableArray *rects = [NSMutableArray new];
            {
                for (UITextSelectionRect *selectionRect in selectionRects) {
                    CGRect rect = selectionRect.rect;
                    if (!CGRectIsEmpty(rect)) { // 会有一些无效的 rect.
                        [rects addObject:[NSValue valueWithCGRect:rect]];
                    }
                }
            }
            link.rects = rects;
        }

        self.selectable = NO; // 关闭选中功能,否则长按链接会出现选中效果.

        _links = links;
    }
    return _links;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];

    self.links = nil; // 每次重设 attributedText 后清空懒加载,从而重新加载.
}

#pragma mark - 触摸处理

- (LXStatusTextLink *)linkWithPoint:(CGPoint)point
{
    for (LXStatusTextLink *link in self.links) {
        for (NSValue *rectValue in link.rects) {
            CGRect rect = [rectValue CGRectValue];
            // 找到了触摸点对应的 link.
            if (CGRectContainsPoint(rect, point)) {
                return link;
            }
        }
    }
    return nil;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self pointInside:point withEvent:event]) {
        self.touchedLink = [self linkWithPoint:point];
        return _touchedLink ? self : nil;
    }
    return nil;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self showLinkBackgroundViewWithLink:_touchedLink];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removelinkBackgroundView];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removelinkBackgroundView];
}

#pragma mark - 添加|移除高亮背景

- (void)showLinkBackgroundViewWithLink:(LXStatusTextLink *)link
{
    if ([link.text hasPrefix:@"http://"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link.text]];
        return;
    }

    for (NSValue *rectValue in link.rects) {
        UIView *bgView = [[UIView alloc] initWithFrame:rectValue.CGRectValue];
        {
            bgView.cornerRadius = 3;
            bgView.tag = kLinkBackgroundTag; // 方便移除.
            bgView.backgroundColor = [UIColor purpleColor];
        }
        [self insertSubview:bgView atIndex:0];
    }
}

- (void)removelinkBackgroundView
{
    for (UIView *childView in self.subviews) {
        if (childView.tag == kLinkBackgroundTag) {
            [childView removeFromSuperview];
        }
    }
}

@end