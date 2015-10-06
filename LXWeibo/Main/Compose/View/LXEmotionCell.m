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
#import "LXMagnifierView.h"
#import "LXEmotionButton.h"
#import "LXEmotionKeyboard.h"

@interface LXEmotionCell () {
    struct {
        BOOL didTapEmotionButton;
    } _delegateFlags;
}
@end

@implementation LXEmotionCell

#pragma mark - 添加按钮

- (void)setEmotionLayoutInfo:(LXEmotionLayoutInfo)emotionLayoutInfo
{
    _emotionLayoutInfo = emotionLayoutInfo;
    
    NSUInteger rowCount = emotionLayoutInfo.emotionCountPerCol;
    NSUInteger colCount = emotionLayoutInfo.emotionCountPerRow;

    for (NSUInteger row = 0; row < rowCount; ++row) {
        for (NSUInteger col = 0; col < colCount; ++col) {

            LXEmotionButton *emotionButton = [LXEmotionButton buttonWithType:UIButtonTypeCustom];
            {
                // 每个表情页最后一个按钮总是删除按钮.
                if (row == rowCount - 1 && col == colCount - 1) {
                    emotionButton.isDeleteButton = YES;
                } else {
                    // 该字号下 emoji 表情大小比较适中.
                    emotionButton.titleLabel.font = [UIFont systemFontOfSize:30];

                    emotionButton.adjustsImageWhenHighlighted = NO;

                    [emotionButton addObserver:self
                                    forKeyPath:@"highlighted"
                                       options:0
                                       context:(__bridge void *)self];
                }

                [emotionButton addTarget:self
                                  action:@selector(emotionButtonDidTap:)
                        forControlEvents:UIControlEventTouchUpInside];
            }
            [self.contentView addSubview:emotionButton];
        }
    }
}

#pragma mark - 加载表情图片

- (void)setEmotions:(NSArray<LXEmotion *> *)emotions
{
    _emotions = [emotions copy];

    [emotions enumerateObjectsUsingBlock:
     ^(LXEmotion * _Nonnull emotion, NSUInteger idx, BOOL * _Nonnull stop) {
         [self.contentView.subviews[idx] setEmotion:emotion];
    }];
}

#pragma mark - 布局

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat emotionSize = self.emotionLayoutInfo.emotionSize;
    NSUInteger rowCount = self.emotionLayoutInfo.emotionCountPerCol;
    NSUInteger colCount = self.emotionLayoutInfo.emotionCountPerRow;

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

#pragma mark - 监听表情按钮高亮变化

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == (__bridge void *)self) {
        if ([object isHighlighted]) {
            self.magnifierView.hidden = NO;
            self.magnifierView.emotion = [object emotion];
            self.magnifierView.anchorPoint = [self convertPoint:[object center]
                                                         toView:self.magnifierView.superview];
        } else {
            self.magnifierView.hidden = YES;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 监听按钮点击

- (void)emotionButtonDidTap:(LXEmotionButton *)sender
{
    if (sender.isDeleteButton) {
        [NSNotificationCenter lx_postNotificationName:LXEmotionKeyboardDidDeleteEmotionNotification
                                               object:nil];
    } else {
        [NSNotificationCenter lx_postNotificationName:LXEmotionKeyboardDidSelectEmotionNotification
                                               object:nil
                                             userInfo:@{ LXEmotionKeyboardSelectedEmotionUserInfoKey : sender.emotion }];
    }
}

@end