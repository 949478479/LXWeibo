//
//  LXComposeViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/1.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXEmotion.h"
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

- (void)dealloc
{
    LXLog(@"%@ delloc", self);

    [NSNotificationCenter lx_removeObserver:self];
    [NSNotificationCenter lx_removeObserver:_keyboardObserver];
    [NSNotificationCenter lx_removeObserver:_textView
                                       name:LXEmotionKeyboardDidDeleteEmotionNotification
                                     object:nil];
}

#pragma mark - View 生命周期方法

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupTitleView];

    [self observeKeyboardChangeFrame];

    [self observeEmotionKeyboard];
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

- (NSString *)statusText
{
    NSMutableString *statusText = [NSMutableString new];
    {
        NSAttributedString *attributedText = self.textView.attributedText;
        {
            [attributedText enumerateAttributesInRange:(NSRange){0, attributedText.length}
                                               options:0
                                            usingBlock:
             ^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {

                 NSTextAttachment *textAttachment = attrs[@"NSAttachment"];
                 if (textAttachment) { // 图片表情.
                     [statusText appendString:[textAttachment lx_valueForKey:@"emotionCHS"]];
                 } else { // 文字或者 emoji 表情.
                     [statusText appendString:[attributedText attributedSubstringFromRange:range].string];
                 }
             }];
        }
    }

    LXLog(@"%@", statusText);

    return statusText;
}

- (void)sendStatusWithoutImage
{
    NSDictionary *params = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                              @"status"       : self.statusText, };

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
                              @"status"       : self.statusText, };

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

#pragma mark - 表情输入|删除

- (void)observeEmotionKeyboard
{
    [NSNotificationCenter lx_addObserver:self
                                selector:@selector(emotionKeyboardSelectedEmotion:)
                                    name:LXEmotionKeyboardDidSelectEmotionNotification
                                  object:nil];

    [NSNotificationCenter lx_addObserver:self.textView
                                selector:@selector(deleteBackward)
                                    name:LXEmotionKeyboardDidDeleteEmotionNotification
                                  object:nil];
}

- (void)emotionKeyboardSelectedEmotion:(NSNotification *)notification
{
    LXEmotion *emotion = notification.userInfo[LXEmotionKeyboardSelectedEmotionUserInfoKey];

    if (emotion.png) { // 图片表情.
        [self insertEmotionAttributedStringWithEmotion:emotion];
    } else { // emoji 表情.
        [self.textView insertText:emotion.emoji];
    }
}

- (void)insertEmotionAttributedStringWithEmotion:(LXEmotion *)emotion
{
    UIFont *font = self.textView.font;
    NSUInteger cursorLocation = self.textView.selectedRange.location; // 获取当前光标位置.

    NSTextAttachment *textAttachment = [NSTextAttachment new];
    {
        UIImage *image = [UIImage imageNamed:emotion.png];

        textAttachment.image = image;
        [textAttachment lx_setValue:emotion.chs forKey:@"emotionCHS"];

        // 设置图片高度为字体行高,宽度根据纵横比计算得出.默认 y 坐标会偏上,设置该值为 font.descender 即可水平对齐.
        CGFloat lineHeight = font.lineHeight;
        CGFloat radio = image.size.height / image.size.width;
        textAttachment.bounds = CGRectMake(0, font.descender, lineHeight / radio, lineHeight);
    }

    NSAttributedString *imageAttributedString =
    [NSAttributedString attributedStringWithAttachment:textAttachment];

    NSMutableAttributedString *attributedString = self.textView.attributedText.mutableCopy;
    {
        // 插入到当前光标位置.
        [attributedString insertAttributedString:imageAttributedString
                                         atIndex:cursorLocation];

        // 设置富文本会导致 textView 的 font 变为另一种富文本默认字体,因此需要专门指定字体为原先字体.
        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:(NSRange){0,attributedString.length}];
    }

    self.textView.attributedText = attributedString;
    self.textView.selectedRange  = NSMakeRange(cursorLocation + 1, 0); // 恢复光标位置到插入点后.
}

#pragma mark - 禁用/允许发表按钮

- (void)textViewDidChange:(UITextView *)textView
{
    self.sendButtonItem.enabled = textView.hasText;
}

@end