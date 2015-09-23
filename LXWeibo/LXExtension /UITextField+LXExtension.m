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
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 添加左侧图标

- (void)setLeftImage:(UIImage *)leftImage
{
    UIImageView *leftView = [[UIImageView alloc] initWithImage:leftImage];
    leftView.lx_size      = CGSizeMake(self.lx_height, self.lx_height);
    leftView.contentMode  = UIViewContentModeCenter;

    self.leftView     = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

- (UIImage *)leftImage
{
    if ([self.leftView isKindOfClass:[UIImageView class]]) {
        return ((UIImageView *)self.leftView).image;
    }
    return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 设置编辑区域范围

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

    if (CGRectIsNull(newRect)) {
        return oldRect;
    }

    CGSize  oldSize   = oldRect.size;
    CGPoint oldOrigin = oldRect.origin;

    CGSize  newSize   = newRect.size;
    CGPoint newOrigin = newRect.origin;

    return (CGRect) {
        {
            newOrigin.x ?: oldOrigin.x,
            newOrigin.y ?: oldOrigin.y
        },
        {
            newSize.width ?: oldSize.width - (newOrigin.x - oldOrigin.x),
            newSize.height ?: oldSize.height - (newOrigin.y - oldOrigin.y)
        },
    };
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 设置文本区域范围

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

    if (CGRectIsNull(newRect)) {
        return oldRect;
    }

    CGSize  oldSize   = oldRect.size;
    CGPoint oldOrigin = oldRect.origin;

    CGSize  newSize   = newRect.size;
    CGPoint newOrigin = newRect.origin;

    return (CGRect) {
        {
            newOrigin.x ?: oldOrigin.x,
            newOrigin.y ?: oldOrigin.y
        },
        {
            newSize.width ?: oldSize.width - (newOrigin.x - oldOrigin.x),
            newSize.height ?: oldSize.height - (newOrigin.y - oldOrigin.y)
        },
    };
}

@end