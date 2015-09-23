//
//  UIImage+LXExtension.m
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import AVFoundation.AVUtilities;
#import "UIImage+LXExtension.h"

@implementation UIImage (LXExtension)

- (UIImage *)lx_resizedImageWithTargetSize:(CGSize)targetSize
{
    NSAssert(targetSize.width && targetSize.height, @"不合法的参数 targetSize => %@", NSStringFromCGSize(targetSize));

    UIGraphicsBeginImageContextWithOptions(targetSize, NO, self.scale);

    [self drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height)];

    UIImage *targetImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return targetImage;
}

- (CGRect)lx_rectForScaleAspectFitInsideBoundingRect:(CGRect)boundingRect
{
    return AVMakeRectWithAspectRatioInsideRect(self.size, boundingRect);
}

@end