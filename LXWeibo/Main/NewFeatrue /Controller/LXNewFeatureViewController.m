//
//  LXNewFeatureViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/27.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXConst.h"
#import "LXUtilities.h"
#import "AppDelegate.h"
#import "LXNewFeartureCell.h"
#import "LXNewFeatureViewController.h"

static const NSInteger kLXNumberOfItems = 4;
static NSString * const kLXNewFeatureCellIdentifier = @"NewFeatureCell";

@interface LXNewFeatureViewController ()

@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation LXNewFeatureViewController

#pragma mark - 初始配置

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize = screenSize;

    UIPageControl *pageControl = [UIPageControl new];
    {
        pageControl.numberOfPages = kLXNumberOfItems;
        pageControl.pageIndicatorTintColor        = [UIColor lightGrayColor];
        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        pageControl.center = CGPointMake(screenSize.width / 2, screenSize.height - 44);

        self.pageControl = pageControl;
        [self.view addSubview:pageControl];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return kLXNumberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LXNewFeartureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kLXNewFeatureCellIdentifier
                                                                        forIndexPath:indexPath];

    NSString *imageName = [NSString stringWithFormat:@"new_feature_%ld", indexPath.row + 1];

    cell.imageView.image    = [UIImage imageNamed:imageName];
    cell.startButton.hidden = !(indexPath.row == kLXNumberOfItems - 1);
    cell.shareButton.hidden = !(indexPath.row == kLXNumberOfItems - 1);
    
    return cell;
}

#pragma mark - 分页处理

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = round(scrollView.contentOffset.x / scrollView.lx_width);
}

#pragma mark - 隐藏状态栏

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - IBAction

- (IBAction)shareButtonDidTap:(UIButton *)sender
{
    sender.selected = !sender.isSelected;
}

- (IBAction)startButtonDidTap:(UIButton *)sender
{
    [NSUserDefaults lx_setObject:LXBundleShortVersionString() forKey:LXVersionString];
    [NSUserDefaults lx_synchronize];

    [UIStoryboard lx_showInitialVCWithStoryboardName:@"Main"];
}

@end