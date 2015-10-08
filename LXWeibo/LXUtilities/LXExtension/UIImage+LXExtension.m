//
//  UIImage+LXExtension.m
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import AVFoundation.AVUtilities;
#import "UIImage+LXExtension.h"

@implementation UIImage (LXExtension)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 图片缩放

- (UIImage *)lx_resizedImageWithTargetSize:(CGSize)targetSize
                               contentMode:(UIViewContentMode)contentMode
{
    NSAssert(targetSize.width && targetSize.height,
             @"参数 targetSize 的宽高必须大于 0. => %@", NSStringFromCGSize(targetSize));

    CGRect drawingRect = { .size = targetSize }; // 默认为 UIViewContentModeScaleToFill.

    if (contentMode == UIViewContentModeScaleAspectFit)
    {
        CGRect boundingRect = { .size = targetSize };
        targetSize  = [self lx_rectForScaleAspectFitInsideBoundingRect:boundingRect].size;
        drawingRect = CGRectMake(0, 0, targetSize.width, targetSize.height);
    }
    else if (contentMode == UIViewContentModeScaleAspectFill)
    {
        CGFloat radio = self.size.height / self.size.width;

        // 先优先满足宽度,根据纵横比算出高度.
        drawingRect = CGRectMake(0, 0, targetSize.width, targetSize.width * radio);

        if (drawingRect.size.height < targetSize.height) // 若高度不足期望值,说明应优先满足高度.
        {
            // 优先满足高度,根据纵横比计算宽度.
            drawingRect.size = CGSizeMake(targetSize.height / radio, targetSize.height);
            // 绘制区域的原点 x 坐标需向左平移,从而使裁剪区域居中.
            drawingRect.origin.x = -(drawingRect.size.width - targetSize.width) / 2;
        }
        else
        {
            // 在宽度满足期望值的情况下,高度大于等于期望高度.绘制区域原点 y 坐标应向上平移,从而使裁剪区域居中.
            drawingRect.origin.y = -(drawingRect.size.height - targetSize.height) / 2;
        }
    }

    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0);

    [self drawInRect:drawingRect];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return image;
}

- (CGRect)lx_rectForScaleAspectFitInsideBoundingRect:(CGRect)boundingRect
{
    return AVMakeRectWithAspectRatioInsideRect(self.size, boundingRect);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 图片裁剪

- (UIImage *)lx_roundedImageWithBounds:(CGRect)bounds
                           borderWidth:(CGFloat)borderWidth
                           borderColor:(UIColor *)borderColor
{
    NSAssert(bounds.size.width > 0 && bounds.size.height > 0,
             @"参数 bounds 的宽高必须大于 0. => %@", NSStringFromCGRect(bounds));

    NSAssert(bounds.size.width == bounds.size.height,
             @"参数 bounds 的宽高必须相等. => %@", NSStringFromCGRect(bounds));

    NSAssert(borderWidth >= 0, @"参数 borderWidth 不能为负数.");

    // 上下文尺寸需算上 borderWidth.
    CGSize contextSize = { bounds.size.width + 2 * borderWidth, bounds.size.height + 2 * borderWidth };

    UIGraphicsBeginImageContextWithOptions(contextSize, NO, 0);

    if (borderWidth > 0)
    {
        CGRect outerBoundaryRect = { .size = contextSize }; // 外边框区域即上下文区域.

        UIBezierPath *outerBoundary = [UIBezierPath bezierPathWithOvalInRect:outerBoundaryRect];

        [borderColor setFill];
        [outerBoundary fill];
    }

    // 内边框原点需在上下文原点基础上向内调整 borderWidth. 尺寸即为图片裁剪尺寸.
    CGRect innerBoundaryRect = { .origin = { borderWidth, borderWidth }, .size = bounds.size };

    UIBezierPath *innerBoundary = [UIBezierPath bezierPathWithOvalInRect:innerBoundaryRect];

    [innerBoundary addClip];

    // 若裁剪区域原点不在图片左上角,需在内边框原点基础上进行调整,从而使裁剪区域左上角位于内边框原点.
    CGPoint drawingPoint = { borderWidth - bounds.origin.x, borderWidth - bounds.origin.y };

    [self drawAtPoint:drawingPoint];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return image;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - 图片渲染

+ (instancetype)lx_originalRenderingImageNamed:(NSString *)name
{
    return [[self imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (instancetype)lx_imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)cornerRadius
{
    NSAssert(color, @"参数 color 为 nil.");
    NSAssert(size.height > 0 && size.width > 0,
             @"参数 size 的宽高必须大于 0. => %@", NSStringFromCGSize(size));
    NSAssert(cornerRadius >= 0, @"参数 cornerRadius 不能为负数.");

    CGColorRef cg_color = color.CGColor;

    CGFloat alpha = CGColorGetAlpha(cg_color);

    BOOL opaque = (alpha == 1.0 && cornerRadius == 0.0);

    UIGraphicsBeginImageContextWithOptions(size, opaque, 0);

    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), cg_color);

    [[UIBezierPath bezierPathWithRoundedRect:(CGRect){.size = size} cornerRadius:cornerRadius] fill];

    return UIGraphicsGetImageFromCurrentImageContext();
}

@end