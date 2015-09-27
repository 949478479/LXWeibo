//
//  AppDelegate.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "AppDelegate.h"

NSString * const LXVersionString = @"LXVersionString";

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

    [self setupRootViewController];

    return YES;
}

#pragma mark - 配置主题

- (void)configureAppearance
{
    UITabBarItem *tabBarItem = [UITabBarItem appearance];
    {
        NSDictionary *attributes = @{ NSFontAttributeName :
                                          [UIFont systemFontOfSize:kLXTabBarItemTitleFontSize] };

        [tabBarItem setTitleTextAttributes:attributes
                                  forState:UIControlStateNormal];
    }

    UIBarButtonItem *barButtonItem  = [UIBarButtonItem appearance];
    {
        NSDictionary *attributes = @{ NSFontAttributeName :
                                          [UIFont systemFontOfSize:kLXBarButtonItemTitleFontSize] };

        barButtonItem.tintColor = [UIColor lx_colorWithHexString:@"E66C0C"];
        [barButtonItem setTitleTextAttributes:attributes
                                     forState:UIControlStateNormal];
    }

    UINavigationBar *navigationBar  = [UINavigationBar appearance];
    {
        NSDictionary *attributes = @{ NSFontAttributeName :
                                          [UIFont systemFontOfSize:kLXNavigationBarTitleFontSize] };

        [navigationBar setTitleTextAttributes:attributes];
    }

    UITabBar *tabBar = [UITabBar appearance];
    tabBar.tintColor = barButtonItem.tintColor;
}

#pragma mark - 设置根控制器

- (void)setupRootViewController
{
    NSString *currentVersionString = LXBundleShortVersionString();
    NSString *sandboxVersionString = [NSUserDefaults lx_stringForKey:LXVersionString];

    NSComparisonResult result = [sandboxVersionString compare:currentVersionString
                                                      options:NSNumericSearch];;

    NSString *storyboardName = (!sandboxVersionString || result == NSOrderedAscending) ?
        @"NewFeature" : @"Main";

    [UIStoryboard lx_showInitialVCWithStoryboardName:storyboardName];
}

@end