//
//  LXEmotionButton.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/6.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXEmotion;

NS_ASSUME_NONNULL_BEGIN

@interface LXEmotionButton : UIButton

@property (nullable, nonatomic, strong) LXEmotion *emotion;

@property (nonatomic, assign) BOOL isDeleteButton;

@end

NS_ASSUME_NONNULL_END