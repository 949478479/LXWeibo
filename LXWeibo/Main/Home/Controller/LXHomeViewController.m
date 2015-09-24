//
//  LXHomeViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/24.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXTabBar.h"
#import "LXUtilities.h"
#import "LXPopoverView.h"
#import "LXHomeViewController.h"

@interface LXHomeViewController () <LXPopoverViewDelegate>

@property (nonatomic, strong) LXPopoverView *popover;

@property (nonatomic, weak) IBOutlet UIButton *titleButton;

@end

@implementation LXHomeViewController

#pragma mark - IBAction

- (IBAction)titleButtonDidTapped:(UIButton *)sender
{
    if (sender.isSelected)
    {
        sender.selected = NO;

        [_popover dismiss];
        _popover = nil;
    }
    else
    {
        sender.selected = YES;
        
        UITableViewController *contentVC = [UITableViewController new];
        contentVC.view.lx_size = CGSizeMake(200, 300);

        _popover = [[LXPopoverView alloc] initWithViewController:contentVC];

        _popover.delegate = self;
        _popover.passthroughViews = @[_titleButton];

        [_popover presentFromView:_titleButton];
    }
}

#pragma mark - LXPopoverViewDelegate

- (void)popoverViewDidDismiss:(LXPopoverView *)popoverView
{
    _popover = nil;
    _titleButton.selected = NO;
}

@end