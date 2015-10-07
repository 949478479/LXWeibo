//
//  LXMagnifierView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/6.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXEmotionButton.h"
#import "LXMagnifierView.h"

@interface LXMagnifierView ()

@property (nonatomic, weak) IBOutlet LXEmotionButton *emotionButton;

@end

@implementation LXMagnifierView

- (void)showFromEmotionButton:(LXEmotionButton *)emotionButton
{
    CGPoint anchorPoint = [emotionButton.superview convertPoint:emotionButton.center
                                                         toView:self.superview];
    self.hidden = NO;

    self.emotionButton.emotion = emotionButton.emotion;
    
    self.center = CGPointMake(anchorPoint.x, anchorPoint.y - self.lx_height / 2);
}

- (void)hidden
{
    self.hidden = YES;
}

@end