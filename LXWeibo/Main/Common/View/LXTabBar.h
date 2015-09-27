//
//  LXTabBar.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/24.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXTabBar;

NS_ASSUME_NONNULL_BEGIN

@protocol LXTabBarDelegate <UITabBarDelegate>
@optional
- (void)tabBar:(LXTabBar *)tabBar didTappedComposeButton:(UIButton *)composeButton;

@end

@interface LXTabBar : UITabBar

@property (nullable, nonatomic, weak) id<LXTabBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END