//
//  AppDelegate.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "AppDelegate.h"

static const CGFloat kLXTabBarItemTitleFontSize    = 11;
static const CGFloat kLXBarButtonItemTitleFontSize = 14;
static const CGFloat kLXNavigationBarTitleFontSize = 18;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureAppearance];

    return YES;
}

- (void)configureAppearance
{
    UITabBar *tabBar = [UITabBar appearance];
    tabBar.tintColor = [UIColor lx_colorWithHexString:@"E66C0C"];

    UITabBarItem *tabBarItem = [UITabBarItem appearance];
    [tabBarItem setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:kLXTabBarItemTitleFontSize] }
                              forState:UIControlStateNormal];

    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    barButtonItem.tintColor        = tabBar.tintColor;
    [barButtonItem setTitleTextAttributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:kLXBarButtonItemTitleFontSize] }
                                 forState:UIControlStateNormal];

    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setTitleTextAttributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:kLXNavigationBarTitleFontSize] }];
}

@end