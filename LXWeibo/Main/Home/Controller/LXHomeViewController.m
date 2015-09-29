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
#import "MJExtension.h"
#import "AFNetworking.h"
#import "LXPopoverView.h"
#import "LXOAuthInfoManager.h"
#import "LXOriginalStatusCell.h"
#import "LXHomeViewController.h"
#import "UIImageView+WebCache.h"

static NSString * const kLXOriginalStatusCellIdentifier = @"LXOriginalStatusCell";
static NSString * const kLXUserInfoURLString            = @"https://api.weibo.com/2/users/show.json";
static NSString * const kLXHomeStatusURLString          = @"https://api.weibo.com/2/statuses/home_timeline.json";
static NSString * const kLXUnreadCountURLString         = @"https://rm.api.weibo.com/2/remind/unread_count.json";

@interface LXHomeViewController () <LXPopoverViewDelegate>

@property (nonatomic, strong) LXPopoverView *popover;
@property (nonatomic, weak) IBOutlet UIButton *titleButton;

@property (nonatomic, strong) NSMutableArray<LXStatus *> *statuses;
@property (nonatomic, strong) NSMutableArray *rowHeightCache;
@property (nonatomic, strong) LXOriginalStatusCell *templateCell;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation LXHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTitle];

    [self setupRefreshControl];

    [self.tableView.header beginRefreshing];

    __weak __typeof(self) weakSelf = self;
    self.timer = LXGCDTimer(60, 30, ^{
        [weakSelf setupUnreadCount];
    }, nil);
    dispatch_resume(self.timer);
}

- (void)setupTitle
{
    LXOAuthInfo *OAuthInfo = [LXOAuthInfoManager OAuthInfo];

    self.titleButton.lx_normalTitle = OAuthInfo.name ?: @"首页";

    NSDictionary *parameters = @{ @"uid"          : OAuthInfo.uid,
                                  @"access_token" : OAuthInfo.access_token, };

    [[AFHTTPRequestOperationManager manager] GET:kLXUserInfoURLString
                                      parameters:parameters
                                         success:
     ^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary * _Nonnull responseObject) {

         LXLog(@"加载用户昵称请求完成!");

         NSString *name = responseObject[@"name"];

         NSAssert(name, @"返回 JSON 中获取的 name 为 nil.");

         if (![OAuthInfo.name isEqualToString:name])
         {
             self.titleButton.lx_normalTitle = name;

             [OAuthInfo setValue:name forKey:@"name"];
             [LXOAuthInfoManager saveOAuthInfo:OAuthInfo];
         }
         
     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
         LXLog(@"加载用户昵称请求出错\n%@", error);
     }];
}

- (void)setupRefreshControl
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                             refreshingAction:@selector(loadNewStatuses)];
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self
                                                                 refreshingAction:@selector(loadMoreStatuses)];
}

- (void)loadMoreStatuses
{
    NSString *maxID = self.statuses.lastObject.idstr;

    NSAssert(maxID, @"maxID 为 nil.");

    NSDictionary *parameters = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                                  @"max_id"       : @(maxID.longLongValue - 1), };

    [[AFHTTPRequestOperationManager manager] GET:kLXHomeStatusURLString
                                      parameters:parameters
                                         success:
     ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

         LXLog(@"加载微博请求完成!");

         NSArray *statusDictionaries  = responseObject[@"statuses"];
         NSMutableArray *moreStatuses = [LXStatus objectArrayWithKeyValuesArray:statusDictionaries];

         NSMutableArray *indexPaths = [NSMutableArray new];
         {
             NSInteger startIndex = self.statuses.count;
             NSInteger endIndex   = startIndex + statusDictionaries.count - 1;
             for (NSInteger row = startIndex; row <= endIndex; ++row) {
                 [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
             }
         }

         [self.statuses addObjectsFromArray:moreStatuses];

         [self.tableView.footer endRefreshing];
         [self.tableView insertRowsAtIndexPaths:indexPaths
                               withRowAnimation:UITableViewRowAnimationNone];

     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
         LXLog(@"加载微博请求出错\n%@", error);
     }];
}

- (void)loadNewStatuses
{
    NSString *sinceID = self.statuses.firstObject.idstr;

    NSDictionary *parameters = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                                  @"since_id"     : sinceID ?: @"0", };

    [[AFHTTPRequestOperationManager manager] GET:kLXHomeStatusURLString
                                      parameters:parameters
                                         success:
     ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

         LXLog(@"加载微博请求完成!");

         NSArray *statusDictionaries = responseObject[@"statuses"];
         NSMutableArray *newStatuses = [LXStatus objectArrayWithKeyValuesArray:statusDictionaries];

         if (self.statuses.count > 0) {

             NSInteger startIndex = 0;
             NSInteger endIndex   = statusDictionaries.count - 1;
             NSMutableArray *indexPaths = [NSMutableArray new];

             for (NSInteger row = startIndex; row <= endIndex; ++row) {
                 [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
                 [self.statuses insertObject:newStatuses[row] atIndex:row];
                 [self.rowHeightCache insertObject:[NSNull null] atIndex:row];
             }

             [self.tableView insertRowsAtIndexPaths:indexPaths
                                   withRowAnimation:UITableViewRowAnimationNone];
         } else {
             self.statuses = newStatuses;
             [self.tableView reloadData];
         }

         [self.tableView.header endRefreshing];
         [self showNewStatusCount:statusDictionaries.count];

     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
         LXLog(@"加载微博请求出错\n%@", error);
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
        label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline_new_status_background"]];
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

- (void)setupUnreadCount
{
    LXOAuthInfo *OAuthInfo = [LXOAuthInfoManager OAuthInfo];

    NSDictionary *parameters = @{ @"uid"          : OAuthInfo.uid,
                                  @"access_token" : OAuthInfo.access_token, };

    [[AFHTTPRequestOperationManager manager] GET:kLXUnreadCountURLString
                                      parameters:parameters
                                         success:
     ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

         NSString *unreadCount = [responseObject[@"status"] description];
         LXLog(@"获取未读数完成! %@", unreadCount);
         if ([unreadCount isEqualToString:@"0"]) {
             unreadCount = nil;
         }
         self.navigationController.tabBarItem.badgeValue = unreadCount;
         [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount.integerValue;

     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
         LXLog(@"获取未读数出错\n%@", error);
     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statuses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXOriginalStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:kLXOriginalStatusCellIdentifier
                                                                 forIndexPath:indexPath];
    [cell configureWithStatus:self.statuses[indexPath.row]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (LXOriginalStatusCell *)templateCell
{
    if (!_templateCell) {
        _templateCell = [self.tableView dequeueReusableCellWithIdentifier:kLXOriginalStatusCellIdentifier];
    }
    return _templateCell;
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

    if (row < count) {
        id rowHeightNumber = self.rowHeightCache[row];
        if (rowHeightNumber != [NSNull null]) {
            return [rowHeightNumber doubleValue]; // 命中缓存.
        }
    }

    CGFloat rowHeight = [self.templateCell heightWithStatus:self.statuses[indexPath.row]];

    if (row < count) {
        self.rowHeightCache[row] = @(rowHeight);
    } else {
        [self.rowHeightCache addObject:@(rowHeight)];
    }

    return rowHeight;
}

#pragma mark - IBAction

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

#pragma mark - LXPopoverViewDelegate

- (void)popoverViewDidDismiss:(LXPopoverView *)popoverView
{
    self.popover = nil;
    self.titleButton.selected = NO;
}

@end