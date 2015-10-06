//
//  LXMagnifierView.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/6.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXEmotionButton;

NS_ASSUME_NONNULL_BEGIN

@interface LXMagnifierView : UIView

- (void)showFromEmotionButton:(LXEmotionButton *)emotionButton;

- (void)hidden;

@end

NS_ASSUME_NONNULL_END