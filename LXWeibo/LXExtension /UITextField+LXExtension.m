//
//  UITextField+LXExtension.m
//
//  Created by 从今以后 on 15/9/11.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import ObjectiveC.runtime;
#import "LXUtilities.h"
#import "UITextField+LXExtension.h"

#pragma clang diagnostic ignored "-Wgnu-conditional-omitted-operand"

@implementation UITextField (LXExtension)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 方法交换

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LXMethodSwizzling([self class], @selector(textRectForBounds:), @selector(lx_textRectForBounds:));
        LXMethodSwizzling([self class], @selector(editingRectForBounds:), @selector(lx_editingRectForBounds:));
        LXMethodSwizzling([self class], @selector(leftViewRectForBounds:), @selector(lx_leftViewRectForBounds:));
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 添加左视图

- (void)setLeftViewImage:(UIImage *)leftViewImage
{
    UIImageView *leftView = [[UIImageView alloc] initWithImage:leftViewImage];
    leftView.lx_size      = CGSizeMake(self.lx_height, self.lx_height);
    leftView.contentMode  = UIViewContentModeCenter;

    self.leftView     = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (UIImage *)leftViewImage
{
    if ([self.leftView isKindOfClass:[UIImageView class]]) {
        return ((UIImageView *)self.leftView).image;
    }
    return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 调整 frame 的辅助函数

static inline CGRect LXAdjustRectForOldRectAndNewRect(CGRect oldRect, CGRect newRect)
{
    if (CGRectIsNull(newRect)) {
        return oldRect;
    }

    CGSize  oldSize   = oldRect.size;
    CGPoint oldOrigin = oldRect.origin;

    CGSize  newSize   = newRect.size;
    CGPoint newOrigin = newRect.origin;

    return (CGRect) {
        {
            newOrigin.x >= 0 ? newOrigin.x : oldOrigin.x,
            newOrigin.y >= 0 ? newOrigin.y : oldOrigin.y,
        },
        {
            newSize.width >= 0 ? newSize.width : oldSize.width - (newOrigin.x - oldOrigin.x),
            newSize.height >= 0 ? newSize.height : oldSize.height - (newOrigin.y - oldOrigin.y),
        },
    };
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 设置编辑区域 frame

- (void)setEditingRect:(CGRect)editingRect
{
    objc_setAssociatedObject(self,
                             @selector(editingRect),
                             [NSValue valueWithCGRect:editingRect],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)editingRect
{
    NSValue *rectValue = objc_getAssociatedObject(self, _cmd);

    return rectValue ? [rectValue CGRectValue] : CGRectNull;
}

- (CGRect)lx_editingRectForBounds:(CGRect)bounds
{
    CGRect oldRect = [self lx_editingRectForBounds:bounds];
    CGRect newRect = [self editingRect];

    return LXAdjustRectForOldRectAndNewRect(oldRect, newRect);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 设置文本区域 frame

- (void)setTextRect:(CGRect)textRect
{
    objc_setAssociatedObject(self,
                             @selector(textRect),
                             [NSValue valueWithCGRect:textRect],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)textRect
{
    NSValue *rectValue = objc_getAssociatedObject(self, _cmd);

    return rectValue ? [rectValue CGRectValue] : CGRectNull;
}

- (CGRect)lx_textRectForBounds:(CGRect)bounds
{
    CGRect oldRect = [self lx_textRectForBounds:bounds];
    CGRect newRect = [self textRect];

    return LXAdjustRectForOldRectAndNewRect(oldRect, newRect);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 设置左视图 frame

- (void)setLeftViewRect:(CGRect)leftViewRect
{
    objc_setAssociatedObject(self,
                             @selector(leftViewRect),
                             [NSValue valueWithCGRect:leftViewRect],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)leftViewRect
{
    NSValue *rectValue = objc_getAssociatedObject(self, _cmd);

    return rectValue ? [rectValue CGRectValue] : CGRectNull;
}

- (CGRect)lx_leftViewRectForBounds:(CGRect)bounds
{
    CGRect oldRect = [self lx_leftViewRectForBounds:bounds];
    CGRect newRect = [self leftViewRect];

    if (CGRectIsNull(newRect)) {
        return oldRect;
    }

    CGSize  oldSize   = oldRect.size;
    CGPoint oldOrigin = oldRect.origin;

    CGSize  newSize   = newRect.size;
    CGPoint newOrigin = newRect.origin;

    return (CGRect) {
        {
            newOrigin.x >= 0 ? newOrigin.x : oldOrigin.x,
            newOrigin.y >= 0 ? newOrigin.y : oldOrigin.y,
        },
        {
            newSize.width >= 0 ? newSize.width : oldSize.width,
            newSize.height >= 0 ? newSize.height : oldSize.height,
        },
    };
}

@end