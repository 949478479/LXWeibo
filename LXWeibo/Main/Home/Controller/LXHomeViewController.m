//
//  LXHomeViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/24.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXTabBar.h"
#import "LXStatus.h"
#import "MJRefresh.h"
#import "LXUtilities.h"
#import "LXStatusCell.h"
#import "LXStatusManager.h"
#import "LXPopoverView.h"
#import "LXOAuthInfoManager.h"
#import "LXHomeViewController.h"
#import "MBProgressHUD+LXExtension.h"

static NSString * const kStatusCellIdentifier = @"LXStatusCell";

@interface LXHomeViewController () <LXPopoverViewDelegate>

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) LXPopoverView *popover;
@property (nonatomic, weak) IBOutlet UIButton *titleButton;

@property (nonatomic, strong) LXStatusCell *statusTemplateCell;
@property (nonatomic, strong) NSMutableArray *rowHeightCache;
@property (nonatomic, strong) NSMutableArray<LXStatus *> *statuses;

@end

@implementation LXHomeViewController

#pragma mark - 初始配置

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerNib];
    [self configureTitle];
    [self configureTimer];
    [self configureRefreshControl];

    [self.tableView.header beginRefreshing];
}

- (void)registerNib
{
    [self.tableView registerNib:[LXStatusCell lx_nib]
         forCellReuseIdentifier:kStatusCellIdentifier];
}

- (void)configureTitle
{
    LXOAuthInfo *OAuthInfo = [LXOAuthInfoManager OAuthInfo];

    self.titleButton.lx_normalTitle = OAuthInfo.name ?: @"首页";

    [LXStatusManager updateUserInfoWithCompletion:^(LXOAuthInfo * _Nonnull OAuthInfo) {
        if (![OAuthInfo.name isEqualToString:self.titleButton.lx_normalTitle]) {
            self.titleButton.lx_normalTitle = OAuthInfo.name;
        }
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD lx_showError:@"网络不给力..."];
    }];
}

- (void)configureTimer
{
    __weak __typeof(self) weakSelf = self;
    self.timer = LXGCDTimer(60, 30, ^{
        [weakSelf updateUnreadCount];
    }, nil);
    dispatch_resume(self.timer);
}

- (void)configureRefreshControl
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                             refreshingAction:@selector(loadNewStatuses)];
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                 refreshingAction:@selector(loadMoreStatuses)];
}

#pragma mark - 加载微博数据

- (void)loadNewStatuses
{
    [LXStatusManager loadNewStatusesSinceStatusID:self.statuses.firstObject.idstr
                                       completion:
     ^(NSArray<LXStatus *> * _Nonnull statuses) {

         [self.tableView.header endRefreshing];
         [self showNewStatusCount:statuses.count];

         if (self.statuses.count > 0) {

             NSInteger startIndex = 0;
             NSInteger endIndex = statuses.count - 1;
             NSMutableArray *indexPaths = [NSMutableArray new];

             for (NSInteger row = startIndex; row <= endIndex; ++row) {
                 [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
                 [self.statuses insertObject:statuses[row] atIndex:row];
                 [self.rowHeightCache insertObject:[NSNull null] atIndex:row];
             }

         } else {
             self.statuses = statuses.mutableCopy;
         }

         [self.tableView reloadData];

     } failure:^(NSError * _Nonnull error) {
         [MBProgressHUD lx_showError:@"网络不给力..."];
         [self.tableView.header endRefreshing];
     }];
}

- (void)loadMoreStatuses
{
    [LXStatusManager loadMoreStatusesAfterStatusID:self.statuses.lastObject.idstr
                                        completion:
     ^(NSArray<LXStatus *> * _Nonnull statuses) {

         NSMutableArray *indexPaths = [NSMutableArray new];
         {
             NSInteger startIndex = self.statuses.count;
             NSInteger endIndex = startIndex + statuses.count - 1;
             for (NSInteger row = startIndex; row <= endIndex; ++row) {
                 [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
             }
         }

         [self.statuses addObjectsFromArray:statuses];

         [self.tableView.footer endRefreshing];
         [self.tableView insertRowsAtIndexPaths:indexPaths
                               withRowAnimation:UITableViewRowAnimationNone];

     } failure:^(NSError * _Nonnull error) {
         [MBProgressHUD lx_showError:@"网络不给力..."];
         [self.tableView.footer endRefreshing];
     }];
}

- (void)showNewStatusCount:(NSUInteger)count
{
    const CGFloat labelHeight = 35;

    UILabel *label = [UILabel new];
    {
        label.frame = (CGRect) {
            .origin = { 0, self.topLayoutGuide.length - labelHeight },
            .size   = { self.view.lx_width, labelHeight },
        };
        label.textColor       = [UIColor whiteColor];
        label.textAlignment   = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor lx_colorWithHexString:@"FF7F00" alpha:0.9];
        
        if (count > 0) {
            label.text = [NSString stringWithFormat:@"共有%lu条新的微博数据", count];
        } else {
            label.text = @"没有新的微博数据,稍后再试~";
        }

        [self.navigationController.view insertSubview:label
                                         belowSubview:self.navigationController.navigationBar];
    }

    {
        const NSTimeInterval duration = 1;

        [UIView animateWithDuration:duration animations:^{
            label.transform = CGAffineTransformMakeTranslation(0, labelHeight);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:duration delay:1 options:(UIViewAnimationOptions)0 animations:^{
                label.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
        }];
    }

    {
        self.navigationController.tabBarItem.badgeValue = nil;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

- (void)updateUnreadCount
{
    [LXStatusManager loadUnreadStatusCountWithCompletion:^(NSString * _Nullable unreadCount) {
        self.navigationController.tabBarItem.badgeValue = unreadCount;
        [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount.integerValue;
    } failure:^(NSError * _Nonnull error) {
        [MBProgressHUD lx_showError:@"网络不给力..."];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statuses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:kStatusCellIdentifier
                                                         forIndexPath:indexPath];
    [cell configureWithStatus:self.statuses[indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (LXStatusCell *)statusTemplateCell
{
    if (!_statusTemplateCell) {
        _statusTemplateCell = [LXStatusCell lx_instantiateFromNib];
    }
    return _statusTemplateCell;
}

- (NSMutableArray<NSNumber *> *)rowHeightCache
{
    if (!_rowHeightCache) {
        _rowHeightCache = [NSMutableArray new];
    }
    return _rowHeightCache;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row   = indexPath.row;
    NSUInteger count = self.rowHeightCache.count;

    // 之前就存在的行.针对滚动中触发此方法的情况.
    if (row < count) {
        id rowHeightNumber = self.rowHeightCache[row];
        if (rowHeightNumber != [NSNull null]) {   // 插入最新微博时会使用 [NSNull null] 作为行高占位.
            return [rowHeightNumber doubleValue]; // 命中缓存.
        }
    }

    CGFloat rowHeight = [self.statusTemplateCell rowHeightWithStatus:self.statuses[row]
                                                         inTableView:tableView];

    // 初次加载或者加载最新微博时,新数据是插入到数组前面的.因此直接替换占位的 [NSNull null].
    if (row < count) {
        NSAssert(self.rowHeightCache[row] == [NSNull null], @"这必须是占位的 [NSNull null].");
        self.rowHeightCache[row] = @(rowHeight);
    }
    // 加载更多微博时新数据是拼接在数组后面的.因此行高数据拼接在后面.
    else {
        [self.rowHeightCache addObject:@(rowHeight)];
    }

    return rowHeight;
}

#pragma mark - 标题按钮交互

- (IBAction)titleButtonDidTap:(UIButton *)sender
{
    if (sender.isSelected)
    {
        sender.selected = NO;

        [self.popover dismiss];
        self.popover = nil;
    }
    else
    {
        sender.selected = YES;
        
        UITableViewController *contentVC = [UITableViewController new];
        contentVC.view.lx_size = CGSizeMake(200, 300);

        self.popover = [[LXPopoverView alloc] initWithViewController:contentVC];

        self.popover.delegate = self;
        self.popover.passthroughViews = @[self.titleButton];

        [self.popover presentFromView:self.titleButton];
    }
}

- (void)popoverViewDidDismiss:(LXPopoverView *)popoverView
{
    self.popover = nil;
    self.titleButton.selected = NO;
}

@end