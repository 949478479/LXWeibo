//
//  LXPhotoBrowserController.m
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "LXPhoto.h"
#import "LXUtilities.h"
#import "LXPhotoBrowserCell.h"
#import "SDWebImagePrefetcher.h"
#import "LXPhotoBrowserController.h"
#import "MBProgressHUD+LXAdditions.h"

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static const CGFloat kPagePadding = 20;
static const NSTimeInterval kAnimationDuration = 0.5; // 试验发现这个数是 modal 动画的时间.
static NSString * const reuseIdentifier = @"LXPhotoBrowserCell";

@interface LXPhotoBrowserController ()
@property (nonatomic) BOOL shouldReshowStatusBar;
@property (nonatomic) IBOutlet UILabel *indexLabel;
@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic) IBOutlet UITapGestureRecognizer *singleTapGestureRecognizer;
@end

@implementation LXPhotoBrowserController

- (void)dealloc
{
    [[SDWebImagePrefetcher sharedImagePrefetcher] cancelPrefetching];
}

#pragma mark 初始化

+ (instancetype)photoBrower
{
    LXPhotoBrowserController *photoBrowser =
        [UIStoryboard lx_instantiateViewControllerWithStoryboardName:@"LXPhotoBrowser"
                                                          identifier:nil];
    return photoBrowser;
}

#pragma mark present/dismiss 动画

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    UIWindow *keyWindow = LXKeyWindow();

    UIView *fadeView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    fadeView.alpha = 0;
    fadeView.backgroundColor = [UIColor blackColor];
    [keyWindow addSubview:fadeView];

    UIImageView *sourceImageView = [_photos[_currentPhotoIndex] sourceImageView];
    NSAssert(sourceImageView, @"sourceImageView 不能为 nil.");
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

    [UIView animateWithDuration:kAnimationDuration animations:^{
        fadeView.alpha = 1.0;
        tempImageView.frame = endFrame;
    } completion:^(BOOL finished) {
        sourceImageView.hidden = NO;
        self.view.hidden = NO;
        [fadeView removeFromSuperview];
        [tempImageView removeFromSuperview];
    }];

    [self hideStatusBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    UIWindow *keyWindow = LXKeyWindow();

    UIView *fadeView = [[UIView alloc] initWithFrame:keyWindow.bounds];
    fadeView.backgroundColor = [UIColor blackColor];
    [keyWindow addSubview:fadeView];

    UIImageView *sourceImageView = [_photos[_currentPhotoIndex] sourceImageView];
    NSAssert(sourceImageView, @"sourceImageView 不能为 nil.");
    sourceImageView.hidden = YES;

    UIImageView *cellImageView = [self.collectionView.visibleCells[0] imageView];
    cellImageView.hidden = YES;

    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:cellImageView.image];
    tempImageView.clipsToBounds = YES;
    tempImageView.contentMode = sourceImageView.contentMode;
    tempImageView.frame = [cellImageView convertRect:cellImageView.bounds toView:keyWindow];
    [keyWindow addSubview:tempImageView];

    self.view.hidden = YES;

    [UIView animateWithDuration:kAnimationDuration animations:^{
        fadeView.alpha = 0;
        tempImageView.frame = [sourceImageView convertRect:sourceImageView.bounds toView:keyWindow];
    } completion:^(BOOL finished) {
        sourceImageView.hidden = NO;
        [fadeView removeFromSuperview];
        [tempImageView removeFromSuperview];
    }];

    if (_shouldReshowStatusBar) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationFade];
    }
}

#pragma mark 隐藏状态栏

- (void)hideStatusBar
{
    NSNumber *boolNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:
                            @"UIViewControllerBasedStatusBarAppearance"];
    // 状态栏由 UIApplication 控制,且当前可见,那么需要隐藏状态栏.
    if (boolNumber && !boolNumber.boolValue && ![UIApplication sharedApplication].statusBarHidden) {
        _shouldReshowStatusBar = YES; // dismiss 后需要重新显示状态栏.
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationFade];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES; // 状态栏由控制器控制,则直接隐藏即可.
}

#pragma mark 基本设置

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_singleTapGestureRecognizer requireGestureRecognizerToFail:_doubleTapGestureRecognizer];

    _indexLabel.hidden = _photos.count < 2;
    // 空四个格是为了能让标签两边留有一定空隙.
    _indexLabel.text = [NSString stringWithFormat:@"%lu/%lu    ",
                        (unsigned long)_currentPhotoIndex + 1, (unsigned long)_photos.count];

    /* 此时子视图的布局尚未完成, collectionView 还是 IB 中的尺寸,并非屏幕尺寸.因此需更新下尺寸,
     否则直接设置 itemSize 会警告超出 collectionView 尺寸而无效. */
    _collectionView.frame = self.view.bounds;
    _flowLayout.itemSize  = self.view.lx_size;
    _collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_currentPhotoIndex inSection:0]
                            atScrollPosition:UICollectionViewScrollPositionNone
                                    animated:NO];
}

#pragma mark 手势处理

- (IBAction)singleTapHandle:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)doubleTapHandle:(UITapGestureRecognizer *)sender
{
    LXPhotoBrowserCell *cell = _collectionView.visibleCells[0];
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

#pragma mark 保存图片

- (IBAction)saveButtonTapHandle:(UIButton *)sender
{
    UIImageWriteToSavedPhotosAlbum([_collectionView.visibleCells[0] imageView].image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    error ? [MBProgressHUD lx_showError:@"保存失败"] : [MBProgressHUD lx_showSuccess:@"保存成功"];
}

#pragma mark 加载图片

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LXPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                        forIndexPath:indexPath];

    __weak __typeof(self) weakSelf = self;
    [cell configureWithPhoto:_photos[indexPath.row] completion:^{
        [weakSelf loadAdjacentImageAtIndex:indexPath.row];
    }];

    return cell;
}

- (void)loadAdjacentImageAtIndex:(NSUInteger)index
{
    NSMutableArray *urls = [NSMutableArray new];

    if (index < _photos.count - 1) {
        NSURL *url = [_photos[index + 1] originalImageURL];
        if (url) {
            [urls addObject:url];
        }
    }

    if (index > 1) {
        NSURL *url = [_photos[index - 1] originalImageURL];
        if (url) {
            [urls addObject:url];
        }
    }

    if (urls.count > 0) {
        [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:urls];
    }
}

#pragma mark 分页处理

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
