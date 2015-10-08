//
//  LXKeyboardSpacingView.h
//
//  Created by 从今以后 on 15/10/8.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface LXKeyboardSpacingView : UIView

/**
 *  是否自动添加 @c H:|-0-[self]-0-| 和 @c V:[self]-0-| 的约束到父视图.
 */
@property (nonatomic, assign) IBInspectable BOOL autoSetupConstraint;

/**
 *  随键盘高度变化的高度约束.键盘收回时为 0, 键盘弹出时为键盘高度.
 */
@property (nonatomic, readonly, strong) IBOutlet NSLayoutConstraint *heightConstraint;

@end

NS_ASSUME_NONNULL_END