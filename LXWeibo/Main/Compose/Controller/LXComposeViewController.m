//
//  LXComposeViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/1.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "AFNetworking.h"
#import "LXOAuthInfoManager.h"
#import "LXComposeViewController.h"
#import "MBProgressHUD+LXExtension.h"

static NSString * const kSendStatusURLString = @"https://api.weibo.com/2/statuses/update.json";

@interface LXComposeViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *sendButtonItem;

@end

@implementation LXComposeViewController

#pragma mark - View 生命周期方法

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTitleView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.textView resignFirstResponder];
}

#pragma mark - 设置标题

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

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.sendButtonItem.enabled = textView.hasText;
}

#pragma mark - IBAction

- (IBAction)sendButtonDidTap:(UIBarButtonItem *)sender
{
    NSDictionary *params = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                              @"status"       : self.textView.text, };

    [[AFHTTPRequestOperationManager manager] POST:kSendStatusURLString
                                       parameters:params
                                          success:
     ^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        [MBProgressHUD lx_showSuccess:@"发送成功"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD lx_showError:@"发送失败"];
        LXLog(@"微博发送失败\n%@", error);
    }];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end