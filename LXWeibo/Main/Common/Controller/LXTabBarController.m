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

@interface LXTabBarController () <LXTabBarDelegate>

@end

@implementation LXTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - LXTabBarDelegate

- (void)tabBar:(LXTabBar *)tabBar didTappedComposeButton:(UIButton *)composeButton
{
    [self performSegueWithIdentifier:@"ModalComposeVC" sender:nil];
}

#pragma mark - Navigation

- (IBAction)unwindForSegue:(UIStoryboardSegue *)unwindSegue
{

}

@end