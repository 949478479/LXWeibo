//
//  LXPhotoBrowserCell.m
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
@property (nonatomic, readwrite) IBOutlet UIImageView *imageView;
@property (nonatomic, readwrite) IBOutlet UIScrollView *scrollView;
@end

@implementation LXPhotoBrowserCell

- (void)dealloc
{
    [_imageView sd_cancelCurrentImageLoad];
}

#pragma mark - 设置图片

- (void)configureWithPhoto:(id<LXPhoto>)photo completion:(void (^)(void))completion
{
    [MBProgressHUD hideHUDForView:self animated:NO]; // 隐藏可能存在的前一次添加的 hud
    __weak __block MBProgressHUD *hud = nil;

    NSURL *url = [photo originalImageURL];
    if (url) {
        __weak __typeof(self) weakSelf = self;
        [_imageView sd_setImageWithURL:url
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
                                 [weakSelf.imageView sizeToFit];
                                 [weakSelf adjustZoomScale];
                                 if (completion) completion();
                             }];
    } else {
        _imageView.image = [photo sourceImageView].image;
    }

    [_imageView sizeToFit];
    [self adjustZoomScale];
}

#pragma mark 调整缩放系数

- (void)adjustZoomScale
{
    // 重置缩放变换，否则设置尺寸会受到缩放影响
    _scrollView.zoomScale = _scrollView.minimumZoomScale = 1.0;

    _scrollView.contentSize = _imageView.image.size;

    // 让最小缩放系数下图片宽度和屏幕相同
    CGFloat zoomScale = LXScreenSize().width / _scrollView.contentSize.width;

    _scrollView.minimumZoomScale = zoomScale;
    if (zoomScale >= 1.0) {
        // zoomScale >= 1.0 说明图片太小，在放大的情况下才能填充。
        // 此时图片已放大至最大，并且无法缩小。为了能触发弹簧效果，需确保 maximumZoomScale > minimumZoomScale。
        _scrollView.maximumZoomScale = zoomScale + CGFLOAT_MIN;
    } else {
        // zoomScale < 1.0 说明图片比较大，需缩小或者原图尺寸才能填充。
        _scrollView.maximumZoomScale = 1.0;
    }

    _scrollView.zoomScale = zoomScale;

    // 让图片能垂直居中显示
    _scrollView.contentOffset = CGPointMake(0, -_scrollView.contentInset.top);
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize screenSize = LXScreenSize();

    // 根据 imageView 实时尺寸调整 contentInset 使之始终能居中显示
    CGFloat paddingH = MAX((screenSize.width - _imageView.lx_width) / 2, 0);
    CGFloat paddingV = MAX((screenSize.height - _imageView.lx_height) / 2, 0);
    scrollView.contentInset = UIEdgeInsetsMake(paddingV, paddingH, paddingV, paddingH);
}

@end
