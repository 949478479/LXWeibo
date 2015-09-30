//
//  AppDelegate.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "AppDelegate.h"
#import "LXOAuthInfoManager.h"
#import "AFHTTPRequestOperationManager.h"

NSString * const LXAppKey    = @"2547705806";
NSString * const LXAppSecret = @"9eede02b85f083f300041d776a8c5118";

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
    [self registerUserNotificationSettings];

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
    if (![LXOAuthInfoManager OAuthInfo]) {
        [UIStoryboard lx_showInitialVCWithStoryboardName:@"OAuth"];
        return;
    }

    NSString *currentVersionString = LXBundleShortVersionString();
    NSString *sandboxVersionString = [NSUserDefaults lx_stringForKey:LXVersionString];

    NSComparisonResult result = [sandboxVersionString compare:currentVersionString
                                                      options:NSNumericSearch];;

    NSString *storyboardName = (!sandboxVersionString || result == NSOrderedAscending) ?
        @"NewFeature" : @"Main";

    [UIStoryboard lx_showInitialVCWithStoryboardName:storyboardName];
}

#pragma mark - 注册通知设置

- (void)registerUserNotificationSettings
{
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge
                                                                             categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

@end