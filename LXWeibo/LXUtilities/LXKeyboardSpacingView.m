//
//  LXKeyboardSpacingView.m
//
//  Created by 从今以后 on 15/10/8.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXKeyboardSpacingView.h"

@interface LXKeyboardSpacingView ()
@property (nonatomic, weak) id keyboardObserver;
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, readwrite, strong) NSLayoutConstraint *heightConstraint;
@end

@implementation LXKeyboardSpacingView

- (void)dealloc
{
    LXLog(@"%@", self.class);
}

- (NSLayoutConstraint *)heightConstraint
{
    if (!_heightConstraint) {
        _heightConstraint =
            [NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(0)]"
                                                    options:0
                                                    metrics:nil
                                                      views:@{ @"self" : self }].firstObject;
        _heightConstraint.active = YES;
    }
    return _heightConstraint;
}

- (void)updateConstraints
{
    [self heightConstraint]; // 懒加载.如果使用 IB 设置了高度约束,则此时 heightConstraint 已经有值了.

    if (_autoSetupConstraint && !_didSetupConstraints) {
        self.didSetupConstraints = YES;
        for (NSString *constraintString in @[@"V:[self]-0-|", @"H:|-0-[self]-0-|"]) {
            [NSLayoutConstraint activateConstraints:
             [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                     options:0
                                                     metrics:nil
                                                       views:@{ @"self" : self }]];
        }
    }

    [super updateConstraints];
}

- (void)didMoveToSuperview
{
    if (self.superview) { // 添加到父视图.
        __weak __typeof(self) weakSelf = self;
        self.keyboardObserver =
        [NSNotificationCenter lx_addObserverForKeyboardWillChangeFrameNotificationWithBlock:
         ^(NSNotification * _Nonnull note) {

             NSDictionary *userInfo  = note.userInfo;
             NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
             CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
             CGFloat keyboardOriginY = CGRectGetMinY(keyboardEndFrame);
             CGFloat keyboardHeight  = CGRectGetHeight(keyboardEndFrame);

             CGFloat constant = (keyboardOriginY < LXScreenSize().height) ? keyboardHeight : 0;
             weakSelf.heightConstraint.constant = constant;

             /* 如果主动注销响应者收回键盘, 例如 endEditing: 或者 resignFirstResponder, keyboardOriginY
              值为 keyboardHeight + LXScreenSize().height 而并非 LXScreenSize().height.
              因此这时候下面的算法会算出负数,造成约束崩溃.
             CGFloat constant = LXScreenSize().height - keyboardOriginY;
             weakSelf.heightConstraint.constant = constant;*/

             [UIView animateWithDuration:duration animations:^{
                 [weakSelf.superview layoutIfNeeded];
             }];
         }];
    } else { // 从父视图移除.
        self.didSetupConstraints = NO;
        [NSNotificationCenter lx_removeObserver:_keyboardObserver];
    }
}

@end