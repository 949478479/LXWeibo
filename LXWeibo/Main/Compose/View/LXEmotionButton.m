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

+ (instancetype)buttonWithType:(UIButtonType)buttonType
{
    LXEmotionButton *button = [super buttonWithType:buttonType];
    button.titleLabel.font = [UIFont systemFontOfSize:32]; // emoji 表情大小.
    return button;
}

#pragma mark - Setter

- (void)setEmotion:(LXEmotion *)emotion
{
    _emotion = emotion;

    if (emotion) {
        if (emotion.png) {
            self.lx_normalTitle = nil;
            self.lx_normalImage = [UIImage lx_originalRenderingImageNamed:emotion.png];
        } else {
            self.lx_normalImage = nil;
            self.lx_normalTitle = emotion.emoji;
        }
    } else {
        self.lx_normalImage = nil;
        self.lx_normalTitle = nil;
    }
}

- (void)setIsDeleteButton:(BOOL)isDeleteButton
{
    _isDeleteButton = isDeleteButton;

    if (isDeleteButton) {
        self.lx_normalImage = [UIImage lx_originalRenderingImageNamed:@"compose_emotion_delete"];
        self.lx_highlightedImage = [UIImage lx_originalRenderingImageNamed:@"compose_emotion_delete_highlighted"];
    } else {
        self.lx_normalImage = nil;
        self.lx_highlightedImage = nil;
    }
    self.lx_normalTitle = nil;
}

@end