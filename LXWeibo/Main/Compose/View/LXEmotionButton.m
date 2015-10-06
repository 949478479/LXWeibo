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

- (void)setEmotion:(LXEmotion *)emotion
{
    _emotion = emotion;

    if (emotion.png) {
        self.lx_normalImage = [UIImage imageNamed:emotion.png];
    } else {
        self.lx_normalTitle = emotion.emoji;
    }
}

- (void)setIsDeleteButton:(BOOL)isDeleteButton
{
    _isDeleteButton = isDeleteButton;

    if (isDeleteButton) {
        self.lx_normalImage = [UIImage imageNamed:@"compose_emotion_delete"];
        self.lx_highlightedImage = [UIImage imageNamed:@"compose_emotion_delete_highlighted"];
    } else {
        self.lx_normalImage = nil;
        self.lx_highlightedImage = nil;
    }
}

@end