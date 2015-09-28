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
#import "LXHomeViewController.h"
#import "UIImageView+WebCache.h"

static NSString * const kLXStatusCellIdentifier = @"kLXStatusCellIdentifier";
static NSString * const kLXUserInfoURLString    = @"https://api.weibo.com/2/users/show.json";
static NSString * const kLXHomeStatusURLString  = @"https://api.weibo.com/2/statuses/home_timeline.json";

@interface LXHomeViewController () <LXPopoverViewDelegate>

@property (nonatomic, strong) LXPopoverView *popover;

@property (nonatomic, weak) IBOutlet UIButton *titleButton;

@property (nonatomic, strong) NSMutableArray<LXStatus *> *statuses;

@end

@implementation LXHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTitle];

    [self setupRefreshControl];

    [self.tableView.header beginRefreshing];
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

         LXLog(@"请求完成!");

         NSString *name = responseObject[@"name"];

         NSAssert(name, @"返回 JSON 中获取的 name 为 nil.");

         if (![OAuthInfo.name isEqualToString:name])
         {
             self.titleButton.lx_normalTitle = name;

             [OAuthInfo setValue:name forKey:@"name"];
             [LXOAuthInfoManager saveOAuthInfo:OAuthInfo];
         }
         
     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
         LXLog(@"%@", error);
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

         LXLog(@"微博请求完成!");

         NSArray *statuses = responseObject[@"statuses"];
         NSMutableArray *moreStatuses = [LXStatus objectArrayWithKeyValuesArray:statuses];
         [self.statuses addObjectsFromArray:moreStatuses];

         [self.tableView.footer endRefreshing];
         [self.tableView reloadData];

     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
         LXLog(@"%@", error);
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

         LXLog(@"微博请求完成!");

         NSArray *statuses = responseObject[@"statuses"];
         NSMutableArray *newStatuses = [LXStatus objectArrayWithKeyValuesArray:statuses];

         if (self.statuses) {
             NSRange indexRange   = { 0,newStatuses.count };
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:indexRange];
             [self.statuses insertObjects:newStatuses atIndexes:indexSet];
         } else {
             self.statuses = newStatuses;
         }

         [self showNewStatusCount:statuses.count];

         [self.tableView.header endRefreshing];
         [self.tableView reloadData];

     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
         LXLog(@"%@", error);
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
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statuses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLXStatusCellIdentifier
                                                            forIndexPath:indexPath];

    LXStatus *status = self.statuses[indexPath.row];

    cell.textLabel.text = status.user.name;
    cell.detailTextLabel.text = status.text;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:status.user.profile_image_url] 
                      placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    return cell;
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