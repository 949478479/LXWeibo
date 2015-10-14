//
//  LXPhotoBrowerController.m
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "LXPhoto.h"
#import "LXUtilities.h"
#import "SDWebImageManager.h"
#import "LXPhotoBrowerCell.h"
#import "LXPhotoBrowerController.h"
#import "MBProgressHUD+LXAdditions.h"

#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

static const CGFloat kPagePadding = 20;
static const NSTimeInterval kAnimatoinDuration = 0.5; // 试验发现这个数是 modal 动画的时间.
static NSString * const reuseIdentifier = @"LXPhotoBrowerCell";

@interface LXPhotoBrowerController ()
@property (nonatomic, weak) IBOutlet UILabel *indexLabel;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *singleTapGestureRecognizer;
@end

@implementation LXPhotoBrowerController

- (void)dealloc
{
    LXLog(@"delloc");
}

#pragma mark - 初始化

+ (instancetype)photoBrower
{
    return [UIStoryboard lx_instantiateViewControllerWithStoryboardName:@"LXPhotoBrower"
                                                             identifier:nil];
}

#pragma mark - present/dismiss 动画

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIWindow *keyWindow = LXKeyWindow();

    UIView *fadeView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    fadeView.alpha = 0;
    fadeView.backgroundColor = [UIColor blackColor];
    [keyWindow addSubview:fadeView];

    UIImageView *sourceImageView = [_photos[_currentPhotoIndex] sourceImageView];
    sourceImageView.hidden = YES;

    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:sourceImageView.image];
    tempImageView.clipsToBounds = YES;
    tempImageView.contentMode = sourceImageView.contentMode;
    tempImageView.frame = [sourceImageView convertRect:sourceImageView.bounds toView:keyWindow];
    [keyWindow addSubview:tempImageView];

    CGSize imageSize  = sourceImageView.image.size;
    CGFloat endWidth  = keyWindow.lx_width;
    CGFloat endHeight = endWidth * imageSize.height / imageSize.width;
    CGFloat endY      = endHeight > keyWindow.lx_height ? 0 : (keyWindow.lx_height - endHeight) / 2;
    CGRect endFrame   = CGRectMake(0, endY, endWidth, endHeight);

    self.view.hidden = YES;

    [UIView animateWithDuration:kAnimatoinDuration animations:^{
        fadeView.alpha = 1.0;
        tempImageView.frame = endFrame;
    } completion:^(BOOL finished) {
        sourceImageView.hidden = NO;
        self.view.hidden = NO;
        [fadeView removeFromSuperview];
        [tempImageView removeFromSuperview];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    UIWindow *keyWindow = LXKeyWindow();

    UIView *fadeView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    fadeView.backgroundColor = [UIColor blackColor];
    [keyWindow addSubview:fadeView];

    UIImageView *sourceImageView = [_photos[_currentPhotoIndex] sourceImageView];
    sourceImageView.hidden = YES;

    UIImageView *cellImageView = [self.collectionView.visibleCells[0] imageView];
    cellImageView.hidden = YES;

    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:cellImageView.image];
    tempImageView.clipsToBounds = YES;
    tempImageView.contentMode = sourceImageView.contentMode;
    tempImageView.frame = [cellImageView convertRect:cellImageView.bounds toView:keyWindow];
    [keyWindow addSubview:tempImageView];

    self.view.hidden = YES;

    [UIView animateWithDuration:kAnimatoinDuration animations:^{
        fadeView.alpha = 0;
        tempImageView.frame = [sourceImageView convertRect:sourceImageView.bounds toView:keyWindow];
    } completion:^(BOOL finished) {
        sourceImageView.hidden = NO;
        [fadeView removeFromSuperview];
        [tempImageView removeFromSuperview];
    }];
}

#pragma mark - 基本设置

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_singleTapGestureRecognizer requireGestureRecognizerToFail:_doubleTapGestureRecognizer];

    _indexLabel.hidden = _photos.count < 2;
    _indexLabel.text = [NSString stringWithFormat:@"%lu/%lu    ",
                        (unsigned long)_currentPhotoIndex + 1, (unsigned long)_photos.count];


    _flowLayout.itemSize = self.view.lx_size;
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPhotoIndex inSection:0]
                            atScrollPosition:UICollectionViewScrollPositionNone
                                    animated:NO];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - 手势处理

- (IBAction)singleTapHandle:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)doubleTapHandle:(UITapGestureRecognizer *)sender
{
    LXPhotoBrowerCell *cell  = _collectionView.visibleCells[0];
    UIImageView *imageView   = cell.imageView;
    UIScrollView *scrollView = cell.scrollView;

    // 当前是最大放大倍率时缩放到最小,在这里也就是初始尺寸.否则以点击位置为中心放大.
    if (scrollView.zoomScale == scrollView.maximumZoomScale) {
        [scrollView setZoomScale:scrollView.minimumZoomScale animated:YES];
    } else {
        CGPoint touchPoint = [sender locationInView:imageView];
        [scrollView zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
    }
}

#pragma mark - 保存图片

- (IBAction)saveButtonTapHandle:(UIButton *)sender
{
    UIImageWriteToSavedPhotosAlbum([_collectionView.visibleCells[0] imageView].image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [MBProgressHUD lx_showError:@"保存失败"];
    } else {
        [MBProgressHUD lx_showSuccess:@"保存成功"];
    }
}

#pragma mark - 加载图片

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LXPhotoBrowerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                        forIndexPath:indexPath];

    __weak __typeof(self) weakSelf = self;
    [cell configureWithPhoto:_photos[indexPath.row] completion:^{
        [weakSelf loadAdjacentImageAtIndex:indexPath.row];
    }];

    return cell;
}

- (void)loadAdjacentImageAtIndex:(NSUInteger)index
{
    void(^downloadImageWithURL)(NSURL *) = ^(NSURL *url) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                        options:(SDWebImageOptions)0
                                                       progress:nil
                                                      completed:^(UIImage *image,
                                                                  NSError *error,
                                                                  SDImageCacheType cacheType,
                                                                  BOOL finished,
                                                                  NSURL *imageURL) {
                                                          // 该 block 参数不能为 nil.
                                                      }];
    };

    if (index < _photos.count - 1) {
        downloadImageWithURL([_photos[index + 1] originalImageURL]);
    }

    if (index > 1) {
        downloadImageWithURL([_photos[index - 1] originalImageURL]);
    }
}

#pragma mark - 分页处理

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat pageWidth = _flowLayout.itemSize.width + kPagePadding;

    CGFloat page = targetContentOffset->x / pageWidth;

    if (velocity.x > 0.0) {
        page = ceil(page);
    } else if (velocity.x < 0.0) {
        page = floor(page);
    } else {
        page = round(page);
    }

    targetContentOffset->x = page * pageWidth;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _flowLayout.itemSize.width + kPagePadding;

    _currentPhotoIndex = round(scrollView.contentOffset.x / pageWidth);

    _indexLabel.text = [NSString stringWithFormat:@"%lu/%lu    ",
                        (unsigned long)_currentPhotoIndex + 1, (unsigned long)_photos.count];
}

@end