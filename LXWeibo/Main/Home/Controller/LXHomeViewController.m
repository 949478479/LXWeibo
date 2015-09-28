//
//  LXHomeViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/24.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXTabBar.h"
#import "LXUtilities.h"
#import "AFNetworking.h"
#import "LXPopoverView.h"
#import "LXOAuthInfoManager.h"
#import "LXHomeViewController.h"

static NSString * const kLXUserInfoURLString = @"https://api.weibo.com/2/users/show.json";

@interface LXHomeViewController () <LXPopoverViewDelegate>

@property (nonatomic, strong) LXPopoverView *popover;

@property (nonatomic, weak) IBOutlet UIButton *titleButton;

@end

@implementation LXHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

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

#pragma mark - IBAction

- (IBAction)titleButtonDidTapped:(UIButton *)sender
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