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
#import "LXComposeTextView.h"
#import "LXEmotionKeyboard.h"
#import "LXOAuthInfoManager.h"
#import "LXComposeViewController.h"
#import "MBProgressHUD+LXExtension.h"

static NSString * const kSendStatusWithImageURLString    = @"https://upload.api.weibo.com/2/statuses/upload.json";
static NSString * const kSendStatusWithoutImageURLString = @"https://api.weibo.com/2/statuses/update.json";

@interface LXComposeViewController () <UITextViewDelegate, LXComposeToolBarDelegate>

@property (nonatomic, weak) IBOutlet LXImagePicker      *imagePicker;
@property (nonatomic, weak) IBOutlet LXComposeTextView  *textView;
@property (nonatomic, weak) IBOutlet LXComposeToolBar   *keyboardToolBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem    *sendButtonItem;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *toolBarBottomConstraint;

@property (nonatomic, weak) id keyboardObserver;
@property (nonatomic, strong) LXEmotionKeyboard *emotionKeyboard;

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

#pragma mark - 发微博

- (IBAction)sendButtonDidTap:(UIBarButtonItem *)sender
{
    self.textView.images.count > 0 ? [self sendStatusWithImage] : [self sendStatusWithoutImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendStatusWithoutImage
{
    NSDictionary *params = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                              @"status"       : self.textView.text, };

    [[AFHTTPRequestOperationManager manager] POST:kSendStatusWithoutImageURLString
                                       parameters:params
                                          success:
     ^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
         LXLog(@"文字微博发表成功!");
         [MBProgressHUD lx_showSuccess:@"发表成功"];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         LXLog(@"文字微博发表失败!\n%@", error);
         [MBProgressHUD lx_showError:@"发表失败"];
     }];
}

- (void)sendStatusWithImage
{
    NSDictionary *params = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                              @"status"       : self.textView.text, };

    __weak __typeof(self) weakSelf = self;
    [[AFHTTPRequestOperationManager manager] POST:kSendStatusWithImageURLString
                                       parameters:params
                        constructingBodyWithBlock:
     ^(id<AFMultipartFormData>  _Nonnull formData) {
         NSData *data = UIImageJPEGRepresentation(weakSelf.textView.images.firstObject, 0);
         [formData appendPartWithFileData:data name:@"pic" fileName:@"xxx.jpg" mimeType:@"image/jpeg"];
     }
                                          success:
     ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
         LXLog(@"图片微博发表成功!");
         [MBProgressHUD lx_showSuccess:@"发表成功"];
     }
                                          failure:
     ^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
         LXLog(@"图片微博发表失败!\n%@", error);
         [MBProgressHUD lx_showError:@"发表失败"];
     }];
}

#pragma mark - 切换键盘|选取照片

- (LXEmotionKeyboard *)emotionKeyboard
{
    if (!_emotionKeyboard) {
        _emotionKeyboard = [LXEmotionKeyboard lx_instantiateFromNib];
    }
    return _emotionKeyboard;
}

- (void)switchKeyboard
{
    if (self.textView.inputView) { // 当前是自定义的表情键盘.
        self.textView.inputView = nil;
        self.keyboardToolBar.showKeyboardButton = NO;
    } else { // 当前是系统键盘.
        self.textView.inputView = self.emotionKeyboard;
        self.keyboardToolBar.showKeyboardButton = YES;
    }

    [self.textView resignFirstResponder];
    LXGCDDelay(0.25, ^{
        [self.textView becomeFirstResponder];
    });
}

- (void)pickImageWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    __weak __typeof(self) weakSelf = self;
    BOOL success = [self.imagePicker presentImagePickerControllerWithSourceType:sourceType
                                                              completionHandler:
                    ^(UIImage * _Nonnull originalImage, UIImage * _Nullable editedImage) {
                        LXLog(@"%@\n%@", originalImage, editedImage);
                        [weakSelf.textView addImage:originalImage];
                    } cancelHandler:^{
                        LXLog(@"图片选择取消.");
                    }];
    if (!success) {
        NSString *errorStr = (sourceType == UIImagePickerControllerSourceTypeCamera) ?
        @"相机不可用!" : @"相册不可用!";
        [MBProgressHUD lx_showError:errorStr];
    }
}

- (void)composeToolBar:(LXComposeToolBar *)composeToolBar
  didTapButtonWithType:(LXComposeToolBarButtonType)type
{
    switch (type) {
        case LXComposeToolBarButtonTypeCamera: {
            LXLog(@"LXComposeToolBar - 相机");
            [self pickImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
        } break;

        case LXComposeToolBarButtonTypePicture: {
            LXLog(@"LXComposeToolBar - 相册");
            [self pickImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        } break;

        case LXComposeToolBarButtonTypeMention: {
            LXLog(@"@ 按钮点击.");
        } break;
            
        case LXComposeToolBarButtonTypeTrend: {
            LXLog(@"# 按钮点击.");
        } break;
        case LXComposeToolBarButtonTypeEmoticon: {
            LXLog(@"表情 按钮点击.");
            [self switchKeyboard];
        } break;
    }
}

#pragma mark - 禁用/允许发表按钮

- (void)textViewDidChange:(UITextView *)textView
{
    self.sendButtonItem.enabled = textView.hasText;
}

@end