//
//  LXEmotionPageCell.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXEmotion.h"
#import "LXUtilities.h"
#import "LXEmotionPageCell.h"
#import "LXMagnifierView.h"
#import "LXEmotionButton.h"
#import "LXEmotionKeyboard.h"
#import "LXRecentEmotionsManager.h"

NS_ASSUME_NONNULL_BEGIN

static const NSUInteger kEmotionCountPerRow = 7;
static const NSUInteger kEmotionCountPerCol = 3;

// 这是放大镜能完整显示在屏幕边缘的距离.
static const CGFloat kMarginH = 12;
static const CGFloat kMarginV = 12;

@interface LXEmotionPageCell () 

@property (nonatomic, strong) NSArray<LXEmotionButton *> *emotionButtons;

@end

@implementation LXEmotionPageCell

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureEmotionButtons];
        [self configureLongPressGestureRecognizer];
    }
    return self;
}

#pragma mark - 添加按钮

- (void)configureEmotionButtons
{
    NSMutableArray *emotionButtons = [NSMutableArray new];

    for (NSUInteger row = 0; row < kEmotionCountPerCol; ++row) {
        for (NSUInteger col = 0; col < kEmotionCountPerRow; ++col) {

            LXEmotionButton *emotionButton = [LXEmotionButton new];
            {
                // 每个表情页最后一个按钮总是删除按钮.
                if (row == kEmotionCountPerCol - 1 && col == kEmotionCountPerRow - 1) {
                    emotionButton.isDeleteButton = YES;
                } else {
                    [emotionButtons addObject:emotionButton];
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
        } break;
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

#pragma mark - 加载表情图片

- (void)setEmotions:(NSArray<LXEmotion *> *)emotions
{
    _emotions = emotions;

    NSUInteger emotionCount = emotions.count;
    NSUInteger emotionButtonCount = self.emotionButtons.count;

    // 更新有表情的按钮的表情.
    for (NSUInteger idx = 0; idx < emotionCount; ++idx) {
        self.emotionButtons[idx].emotion = emotions[idx];
    }

    // 清空没有表情的按钮的之前的表情.
    for (NSUInteger idx = emotionCount; idx < emotionButtonCount; ++idx) {
        self.emotionButtons[idx].emotion = nil;
    }
}

#pragma mark - 布局

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat emotionSize;
    CGFloat marginH  = kMarginH;
    CGFloat marginV  = kMarginV;
    CGFloat emotionW = (self.lx_width - 2 * kMarginH) / kEmotionCountPerRow;
    CGFloat emotionH = (self.lx_height - 2 * kMarginV) / kEmotionCountPerCol;

    // 确保表情按钮是正方形,并且和父视图的左右间距不会小于 kMarginH, 上下间距不会小于 kMarginV.
    if (emotionW > emotionH) {
        emotionSize = emotionH;
        marginH = (self.lx_width - kEmotionCountPerRow * emotionSize) / 2;
    } else {
        emotionSize = emotionW;
        marginV = (self.lx_height - kEmotionCountPerCol * emotionSize) / 2;
    }

    [self.contentView.subviews enumerateObjectsUsingBlock:
     ^(__kindof UIView * _Nonnull emotion, NSUInteger idx, BOOL * _Nonnull stop) {

         NSUInteger row = idx / kEmotionCountPerRow;
         NSUInteger col = idx % kEmotionCountPerRow;

         emotion.frame = CGRectMake(marginH + col * emotionSize,
                                    marginV + row * emotionSize,
                                    emotionSize,
                                    emotionSize);
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
        
        [LXRecentEmotionsManager addEmotion:sender.emotion];
    }
}

@end

NS_ASSUME_NONNULL_END