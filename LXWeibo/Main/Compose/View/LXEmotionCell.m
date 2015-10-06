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

static const CGFloat kMarginH = 20;
static const CGFloat kMarginV = 20;

@interface LXEmotionCell () 

@property (nonatomic, strong) NSArray<LXEmotionButton *> *emotionButtons;

@end

@implementation LXEmotionCell

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureLongPressGestureRecognizer];
    }
    return self;
}

#pragma mark - 长按手势处理

- (void)configureLongPressGestureRecognizer
{
    SEL action = @selector(longPressGestureRecognizerHandle:);
    UILongPressGestureRecognizer *gr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                     action:action];
    [self addGestureRecognizer:gr];
}

- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)gr
{
    CGPoint location = [gr locationInView:self];
    LXEmotionButton *emotionButton = [self emotionButtonWithTouchPoint:location];

    switch (gr.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            if (emotionButton) {
                [self.magnifierView showFromEmotionButton:emotionButton];
            }
        } break;

        default: {
            if (emotionButton) {
                [self emotionButtonDidTap:emotionButton];
            }
            [self.magnifierView hidden];
        }
    }
}

- (LXEmotionButton *)emotionButtonWithTouchPoint:(CGPoint)point
{
    if (!CGRectContainsPoint(self.bounds, point)) {
        return nil;
    }

    for (LXEmotionButton *emotionButton in self.emotionButtons) {
        if (CGRectContainsPoint(emotionButton.frame, point)) {
            return emotionButton;
        }
    }
    return nil;
}

#pragma mark - 添加按钮

- (void)setEmotionLayoutInfo:(LXEmotionLayoutInfo)emotionLayoutInfo
{
    _emotionLayoutInfo = emotionLayoutInfo;
    
    NSUInteger rowCount = emotionLayoutInfo.emotionCountPerCol;
    NSUInteger colCount = emotionLayoutInfo.emotionCountPerRow;

    NSMutableArray *emotionButtons = [NSMutableArray new];

    for (NSUInteger row = 0; row < rowCount; ++row) {
        for (NSUInteger col = 0; col < colCount; ++col) {

            LXEmotionButton *emotionButton = [LXEmotionButton buttonWithType:UIButtonTypeCustom];
            {
                // 每个表情页最后一个按钮总是删除按钮.
                if (row == rowCount - 1 && col == colCount - 1) {
                    emotionButton.isDeleteButton = YES;
                } else {
                    [emotionButtons addObject:emotionButton];
                    emotionButton.titleLabel.font = [UIFont systemFontOfSize:30]; // emoji 表情大小.
                }
                [emotionButton addTarget:self
                                  action:@selector(emotionButtonDidTap:)
                        forControlEvents:UIControlEventTouchUpInside];
            }
            self.emotionButtons = emotionButtons;
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

    NSUInteger rowCount = self.emotionLayoutInfo.emotionCountPerCol;
    NSUInteger colCount = self.emotionLayoutInfo.emotionCountPerRow;

    CGFloat width = (self.lx_width - 2 * kMarginH) / colCount;
    CGFloat height = (self.lx_height - 2 * kMarginV) / rowCount;

    [self.contentView.subviews enumerateObjectsUsingBlock:
     ^(__kindof UIView * _Nonnull emotion, NSUInteger idx, BOOL * _Nonnull stop) {

         NSUInteger row = idx / colCount;
         NSUInteger col = idx % colCount;

         emotion.frame = CGRectMake(kMarginH + col * width, kMarginV + row * height, width, height);
    }];
}

#pragma mark - 监听按钮点击

- (void)emotionButtonDidTap:(LXEmotionButton *)sender
{
    if (sender.isDeleteButton) {
        [NSNotificationCenter lx_postNotificationName:LXEmotionKeyboardDidDeleteEmotionNotification
                                               object:nil];
    } else {
        NSDictionary *userInfo = @{ LXEmotionKeyboardSelectedEmotionUserInfoKey : sender.emotion };
        [NSNotificationCenter lx_postNotificationName:LXEmotionKeyboardDidSelectEmotionNotification
                                               object:nil
                                             userInfo:userInfo];
    }
}

@end