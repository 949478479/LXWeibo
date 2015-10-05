//
//  LXEmotionCell.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXEmotion;

NS_ASSUME_NONNULL_BEGIN

@interface LXEmotionCell : UICollectionViewCell

@property (nonatomic, assign) CGFloat emotionSize;

@property (nonatomic, assign) NSUInteger emotionCountPerRow;
@property (nonatomic, assign) NSUInteger emotionCountPerCol;

@property (nonatomic, copy) NSArray<LXEmotion *> *emotions;

@end

NS_ASSUME_NONNULL_END