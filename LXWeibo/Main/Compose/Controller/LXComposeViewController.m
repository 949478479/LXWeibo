//
//  LXComposeViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/1.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "AFNetworking.h"
#import "LXImagePicker.h"
#import "LXComposeToolBar.h"
#import "LXOAuthInfoManager.h"
#import "LXComposeViewController.h"
#import "MBProgressHUD+LXExtension.h"
#import "MBProgressHUD+LXExtension.h"

static NSString * const kSendStatusURLString = @"https://api.weibo.com/2/statuses/update.json";

@interface LXComposeViewController () <UITextViewDelegate, LXComposeToolBarDelegate>

@property (nonatomic, weak) id keyboardObserver;

@property (nonatomic, weak) IBOutlet UIView *toolBar;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *sendButtonItem;
@property (nonatomic, weak) IBOutlet LXImagePicker *imagePicker;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *toolBarBottomConstraint;

@end

@implementation LXComposeViewController

#pragma mark - View 生命周期方法

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTitleView];

    [self observeKeyboardChangeFrame];
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

#pragma mark - 键盘弹出收回处理

- (void)dealloc
{
    LXLog(@"%@ delloc", self);

    [NSNotificationCenter lx_removeObserver:self];
}

- (void)observeKeyboardChangeFrame
{
    __weak __typeof(self) weakSelf = self;
    self.keyboardObserver =
        [NSNotificationCenter lx_addObserverForKeyboardWillChangeFrameNotificationWithBlock:
         ^(NSNotification * _Nonnull note) {

             NSDictionary *userInfo  = note.userInfo;
             NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
             CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

             CGFloat constant = weakSelf.view.lx_height - CGRectGetMinY(keyboardEndFrame);
             weakSelf.toolBarBottomConstraint.constant = constant;

             [UIView animateWithDuration:duration animations:^{
                 [weakSelf.view layoutIfNeeded];
             }];
         }];
}

#pragma mark - LXComposeToolBarDelegate

- (void)composeToolBar:(LXComposeToolBar *)composeToolBar
  didTapButtonWithType:(LXComposeToolBarButtonType)type
{
    switch (type) {
        case LXComposeToolBarButtonTypeCamera: {
            LXLog(@"LXComposeToolBar - 相机");

            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            BOOL success = [self.imagePicker presentImagePickerControllerWithSourceType:sourceType
                                                                      completionHandler:
                            ^(UIImage * _Nonnull originalImage, UIImage * _Nullable editedImage) {
                                LXLog(@"%@\n%@", originalImage, editedImage);
                            } cancelHandler:^{
                                LXLog(@"图片选择取消.");
                            }];
            if (!success) {
                [MBProgressHUD lx_showError:@"相机不可用!"];
            }
        } break;

        case LXComposeToolBarButtonTypePicture: {
            LXLog(@"LXComposeToolBar - 相册");

            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            BOOL success = [self.imagePicker presentImagePickerControllerWithSourceType:sourceType
                                                                      completionHandler:
                            ^(UIImage * _Nonnull originalImage, UIImage * _Nullable editedImage) {
                                LXLog(@"%@\n%@", originalImage, editedImage);
                            } cancelHandler:^{
                                LXLog(@"图片选择取消.");
                            }];
            if (!success) {
                [MBProgressHUD lx_showError:@"相册不可用!"];
            }
        } break;

        case LXComposeToolBarButtonTypeMention: {
            LXLog(@"@ 按钮点击.");
        } break;
            
        case LXComposeToolBarButtonTypeTrend: {
            LXLog(@"# 按钮点击.");
        } break;
        case LXComposeToolBarButtonTypeEmoticon: {
            LXLog(@"表情 按钮点击.");
        } break;
    }
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