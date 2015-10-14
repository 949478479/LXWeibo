//
//  LXTabBarController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/24.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXTabBar.h"
#import "LXUtilities.h"
#import "LXTabBarController.h"

static const CGFloat kTabBarItemTitleFontSize    = 11;
static const CGFloat kBarButtonItemTitleFontSize = 14;
static const CGFloat kNavigationBarTitleFontSize = 18;

@interface LXTabBarController () <LXTabBarDelegate>

@end

@implementation LXTabBarController

#pragma mark - 初始配置

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureAppearance];
}

- (void)configureAppearance
{
    UITabBarItem *tabBarItem = [UITabBarItem appearance];
    {
        NSDictionary *attributes = @{ NSFontAttributeName :
                                          [UIFont systemFontOfSize:kTabBarItemTitleFontSize] };

        [tabBarItem setTitleTextAttributes:attributes
                                  forState:UIControlStateNormal];
    }

    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    {
        NSDictionary *attributes = @{ NSFontAttributeName :
                                          [UIFont systemFontOfSize:kBarButtonItemTitleFontSize] };

        barButtonItem.tintColor = [UIColor lx_colorWithHexString:@"E66C0C"];
        [barButtonItem setTitleTextAttributes:attributes
                                     forState:UIControlStateNormal];
    }

    UINavigationBar *navigationBar = [UINavigationBar appearance];
    {
        NSDictionary *attributes = @{ NSFontAttributeName :
                                          [UIFont systemFontOfSize:kNavigationBarTitleFontSize] };

        [navigationBar setTitleTextAttributes:attributes];
    }

    UITabBar *tabBar = [UITabBar appearance];
    tabBar.tintColor = barButtonItem.tintColor;
}

#pragma mark - LXTabBarDelegate

- (void)tabBar:(LXTabBar *)tabBar didTappedComposeButton:(UIButton *)composeButton
{
    [self performSegueWithIdentifier:@"ModalComposeVC" sender:nil];
}

#pragma mark - Navigation

- (IBAction)dismissComposeVCForSegue:(UIStoryboardSegue *)unwindSegue { }

@end