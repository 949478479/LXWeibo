//
//  LXPopoverView.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/24.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXPopoverView;

NS_ASSUME_NONNULL_BEGIN

@protocol LXPopoverViewDelegate <NSObject>
@optional
- (void)popoverViewDidDismiss:(LXPopoverView *)popoverView;

@end

@interface LXPopoverView : UIView

@property (nonatomic, strong) UIView *contentView;
@property (nullable, nonatomic, strong) UIViewController *contentVC;

@property (nullable, nonatomic, copy) NSArray<UIView *> *passthroughViews;

@property (nullable, nonatomic, weak) id<LXPopoverViewDelegate> delegate;

- (instancetype)initWithContentView:(UIView *)contentView NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithViewController:(UIViewController *)viewController NS_DESIGNATED_INITIALIZER;

- (void)presentFromView:(UIView *)view;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END