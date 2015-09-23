//
//  UIImage+LXExtension.h
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LXExtension)

/**
 *  缩放图片到目标尺寸(非等比例).
 */
- (UIImage *)lx_resizedImageWithTargetSize:(CGSize)targetSize;

/**
 *  返回图片用 UIViewContentModeScaleAspectFit 模式适应 boundingRect 的图片的 frame.
 */
- (CGRect)lx_rectForScaleAspectFitInsideBoundingRect:(CGRect)boundingRect;

@end

NS_ASSUME_NONNULL_END