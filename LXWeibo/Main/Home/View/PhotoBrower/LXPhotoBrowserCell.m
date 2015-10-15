//
//  LXPhotoBrowerCell.m
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "LXPhoto.h"
#import "LXUtilities.h"
#import "LXPhotoBrowserCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+LXAdditions.h"

@interface LXPhotoBrowserCell () <UIScrollViewDelegate>
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, readwrite, weak) IBOutlet UIScrollView *scrollView;
@end

@implementation LXPhotoBrowerCell

- (void)dealloc
{
    [_imageView sd_cancelCurrentImageLoad];
}

#pragma mark - 设置图片

- (void)configureWithPhoto:(id<LXPhoto>)photo completion:(void (^)(void))completion
{
    [MBProgressHUD hideHUDForView:self animated:NO]; // 隐藏可能存在的前一次添加的 hud.
    __weak __block MBProgressHUD *hud = nil;

    __weak __typeof(self) weakSelf = self;
    [_imageView sd_setImageWithURL:[photo originalImageURL]
                  placeholderImage:[photo sourceImageView].image
                           options:(SDWebImageOptions)0
                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                              if (!hud) {
                                  hud = [MBProgressHUD lx_showProgressHUDToView:self text:nil];
                              }
                              hud.progress = (float)receivedSize / expectedSize;
                          }
                         completed:^(UIImage *image, NSError *error,
                                     SDImageCacheType cacheType,
                                     NSURL *imageURL) {
                             [hud hide:YES];
                             [weakSelf adjustZoomScale];
                             if (completion) {
                                 completion();
                             }
                         }];

    [self adjustZoomScale];
}

#pragma mark -调整缩放系数

- (void)adjustZoomScale
{
    // 防止 minimumZoomScale > 1.0 时限制 zoomScale 无法修改为 1.0 .
    _scrollView.minimumZoomScale = 1.0;
    // 重置缩放变换,否则设置尺寸会受到缩放影响.
    _scrollView.zoomScale = 1.0;

    _imageView.frame = (CGRect){ .size = _imageView.image.size };
    _scrollView.contentSize = _imageView.image.size;

    // 让最小缩放系数下图片宽度和屏幕相同.
    CGFloat zoomScale = self.lx_width / _imageView.lx_width;

    _scrollView.minimumZoomScale = zoomScale;
    // zoomScale >= 1.0 说明图片太小,在放大的情况下才能填充.
    if (zoomScale >= 1.0) {
        // 此时图片已放大至最大,并且无法缩小.为了能触发弹簧效果,需确保 maximumZoomScale > minimumZoomScale.
        _scrollView.maximumZoomScale = zoomScale + 0.000001;
    } else {
        // zoomScale < 1.0 说明图片比较大,需缩小或者原图尺寸才能填充.
        _scrollView.maximumZoomScale = 1.0;
    }

    // 调整当前缩放系数,即若是大图就是以最小形式展示,若是小图就是以最大形式展示(实际上系数小 0.000001).
    _scrollView.zoomScale = zoomScale;

    _scrollView.contentOffset = CGPointMake(0, -_scrollView.contentInset.top);
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // 根据 imageView 实时尺寸调整 contentInset 使之始终能居中显示.
    CGFloat paddingH = _imageView.lx_width < self.lx_width ?
        (self.lx_width - _imageView.lx_width) / 2 : 0;

    CGFloat paddingV = _imageView.lx_height < self.lx_height ?
        (self.lx_height - _imageView.lx_height) / 2 : 0;

    scrollView.contentInset = UIEdgeInsetsMake(paddingV, paddingH, paddingV, paddingH);
}

@end