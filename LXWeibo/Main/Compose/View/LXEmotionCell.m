//
//  LXEmotionCell.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXEmotion.h"
#import "LXUtilities.h"
#import "LXEmotionCell.h"

@implementation LXEmotionCell

#pragma mark - 添加按钮

- (void)addEmotionButton
{
    NSUInteger rowCount = self.emotionCountPerCol;
    NSUInteger colCount = self.emotionCountPerRow;

    for (NSUInteger row = 0; row < rowCount; ++row) {
        for (NSUInteger col = 0; col < colCount; ++col) {

            UIButton *emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            emotionButton.titleLabel.font = [UIFont systemFontOfSize:30]; // 该字号下 emoji 表情大小比较适中.
            [self.contentView addSubview:emotionButton];

            // 每个表情页最后一个按钮总是删除按钮.
            if (row == rowCount - 1 && col == colCount - 1) {
                emotionButton.lx_normalImage = [UIImage imageNamed:@"compose_emotion_delete"];
                emotionButton.lx_highlightedImage = [UIImage imageNamed:@"compose_emotion_delete_highlighted"];
            }
        }
    }
}

#pragma mark - 加载表情图片

- (void)setEmotions:(NSArray<LXEmotion *> *)emotions
{
    _emotions = [emotions copy];

    [self addEmotionButton];

    [emotions enumerateObjectsUsingBlock:
     ^(LXEmotion * _Nonnull emotion, NSUInteger idx, BOOL * _Nonnull stop) {
         
        UIButton *emotionButton = self.contentView.subviews[idx];
        if (emotion.png) {
            emotionButton.lx_normalImage = [UIImage imageNamed:emotion.png];
        } else {
            emotionButton.lx_normalTitle = emotion.emoji;
        }
    }];
}

#pragma mark - 布局

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat emotionSize = self.emotionSize;

    NSUInteger rowCount = self.emotionCountPerCol;
    NSUInteger colCount = self.emotionCountPerRow;

    CGFloat marginH = (self.lx_width - colCount * emotionSize) / (colCount + 1);
    CGFloat marginV = (self.lx_height - rowCount * emotionSize) / (rowCount + 1);

    [self.contentView.subviews enumerateObjectsUsingBlock:
     ^(__kindof UIView * _Nonnull emotion, NSUInteger idx, BOOL * _Nonnull stop) {

         NSUInteger row = idx / colCount;
         NSUInteger col = idx % colCount;

         emotion.frame = CGRectMake(marginH + col * (emotionSize + marginH),
                                    marginV + row * (emotionSize + marginV),
                                    emotionSize,
                                    emotionSize);
    }];
}

@end