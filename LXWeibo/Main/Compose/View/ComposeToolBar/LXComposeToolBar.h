//
//  LXComposeToolBar.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/3.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXComposeToolBar;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LXComposeToolBarButtonType) {
    LXComposeToolBarButtonTypeCamera,
    LXComposeToolBarButtonTypePicture,
    LXComposeToolBarButtonTypeMention,
    LXComposeToolBarButtonTypeTrend,
    LXComposeToolBarButtonTypeEmoticon,
};

@protocol LXComposeToolBarDelegate <NSObject>
@optional
- (void)composeToolBar:(LXComposeToolBar *)composeToolBar
  didTapButtonWithType:(LXComposeToolBarButtonType)type;

@end

@interface LXComposeToolBar : UIView

@property (nonatomic, assign) BOOL showKeyboardButton;

@property (nonatomic, weak) IBOutlet id<LXComposeToolBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END