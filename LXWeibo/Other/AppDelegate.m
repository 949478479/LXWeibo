//
//  AppDelegate.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXConst.h"
#import "LXUtilities.h"
#import "AppDelegate.h"
#import "LXOAuthInfoManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerUserNotificationSettings];

    [self setupRootViewController];

    return YES;
}

#pragma mark - 设置根控制器

- (void)setupRootViewController
{
    if (![LXOAuthInfoManager OAuthInfo]) {
        [UIStoryboard lx_showInitialViewControllerWithStoryboardName:@"OAuth"];
        return;
    }

    NSString *currentVersionString = LXBundleShortVersionString();
    NSString *sandboxVersionString = [NSUserDefaults lx_stringForKey:LXAppVersionString];

    NSComparisonResult result = [sandboxVersionString compare:currentVersionString
                                                      options:NSNumericSearch];;

    NSString *storyboardName = (!sandboxVersionString || result == NSOrderedAscending) ?
        @"NewFeature" : @"Main";

    [UIStoryboard lx_showInitialViewControllerWithStoryboardName:storyboardName];
}

#pragma mark - 注册通知设置

- (void)registerUserNotificationSettings
{
    UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge
                                          categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

@end