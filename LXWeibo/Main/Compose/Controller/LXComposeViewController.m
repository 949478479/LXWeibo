//
//  LXComposeViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/1.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXOAuthInfoManager.h"
#import "LXComposeViewController.h"

@interface LXComposeViewController ()

@end

@implementation LXComposeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTitleView];
}

- (void)setupTitleView
{
    NSString *name  = [LXOAuthInfoManager OAuthInfo].name;
    NSString *title = name ? [NSString stringWithFormat:@"发微博\n%@", name] : @"发微博";

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedString addAttribute:NSFontAttributeName
                             value:[UIFont systemFontOfSize:12]
                             range:(NSRange){4,attributedString.length - 4}];

    UILabel *titleLabel = [UILabel new];
    {
        titleLabel.numberOfLines  = 0;
        titleLabel.attributedText = attributedString;
        titleLabel.textAlignment  = NSTextAlignmentCenter;
        [titleLabel sizeToFit];
    }

    self.navigationItem.titleView = titleLabel;
}

@end