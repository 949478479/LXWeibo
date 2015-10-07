//
//  LXEmotionButton.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/6.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXEmotion.h"
#import "LXUtilities.h"
#import "LXEmotionButton.h"

@implementation LXEmotionButton

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustsImageWhenHighlighted = NO;
        self.titleLabel.font = [UIFont systemFontOfSize:32]; // emoji 表情大小.
        self.lx_highlightedBackgroundImage = [UIImage imageNamed:@"emotion_bg"];
    }
    return self;
}

#pragma mark - Setter

- (void)setEmotion:(LXEmotion *)emotion
{
    _emotion = emotion;

    self.enabled = emotion ? YES : NO;

    if (emotion) {
        if (emotion.png) { // 图片表情.
            self.lx_normalTitle = nil;
            self.lx_normalImage = [UIImage imageNamed:emotion.png];
        } else { // emoji 表情.
            self.lx_normalImage = nil;
            self.lx_normalTitle = emotion.emoji;
        }
    } else { // 没有表情,清空显示内容.
        self.lx_normalImage = nil;
        self.lx_normalTitle = nil;
    }
}

- (void)setIsDeleteButton:(BOOL)isDeleteButton
{
    _isDeleteButton = isDeleteButton;

    if (isDeleteButton) {
        self.lx_normalTitle = nil;
        self.lx_normalImage = [UIImage imageNamed:@"compose_emotion_delete"];
        self.lx_highlightedImage = [UIImage imageNamed:@"compose_emotion_delete_highlighted"];
    } else {
        self.lx_normalImage = nil;
        self.lx_highlightedImage = nil;
    }
}

@end