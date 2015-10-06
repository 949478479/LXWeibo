//
//  LXEmotionCell.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXEmotion, LXMagnifierView;

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    CGFloat    emotionSize;
    NSUInteger emotionCountPerRow;
    NSUInteger emotionCountPerCol;
} LXEmotionLayoutInfo;

@interface LXEmotionCell : UICollectionViewCell

@property (nonatomic, assign) LXEmotionLayoutInfo emotionLayoutInfo;

@property (nonatomic, copy) NSArray<LXEmotion *> *emotions;

@property (nonatomic, weak) LXMagnifierView *magnifierView;

@end

NS_ASSUME_NONNULL_END