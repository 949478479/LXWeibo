//
//  LXMagnifierView.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/6.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXEmotion;

NS_ASSUME_NONNULL_BEGIN

@interface LXMagnifierView : UIView

@property (nonatomic, strong) LXEmotion *emotion;

@property (nonatomic, assign) CGPoint anchorPoint;

@end

NS_ASSUME_NONNULL_END