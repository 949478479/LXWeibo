//
//  AppDelegate.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "AppDelegate.h"

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

    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    barButtonItem.tintColor        = tabBar.tintColor;
}

@end