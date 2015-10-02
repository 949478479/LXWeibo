//
//  LXTextView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/2.
//  Copyright © 2015年 apple. All rights reserved.
//
#import "LXTextView.h"
#import "LXUtilities.h"

@interface LXTextView () 

@property (nonatomic, weak) id observer;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *placeholderLabelConstraints;

@end

@implementation LXTextView

#pragma mark - Setter

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    [super setTextContainerInset:textContainerInset];

    // textContainerInset 改变了更新 placeholderLabel 的位置约束.
    [self updatePlaceholderLabelConstraint];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];

    self.placeholderLabel.font = font;
}

- (void)setText:(NSString *)text
{
    [super setText:text];

    self.placeholderLabel.hidden = self.hasText; // 手动设置 text 属性不会触发通知.
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];

    self.placeholderLabel.font   = self.font;    // 手动设置 attributedText 属性会改变字体.
    self.placeholderLabel.hidden = self.hasText; // 手动设置 attributedText 属性不会触发通知.
}

#pragma mark - 初始配置

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self observeTextDidChange];

    [self configurePlaceholderLabel];
}

#pragma mark - 安装 Placeholder Label

- (void)configurePlaceholderLabel
{
    self.placeholderLabel = [UILabel new];
    self.placeholderLabel.font = self.font;
    self.placeholderLabel.text = self.placeholder;
    self.placeholderLabel.hidden = self.hasText;
    self.placeholderLabel.textColor = self.placeholderColor;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:self.placeholderLabel];

    [self updatePlaceholderLabelConstraint];
}

- (void)updatePlaceholderLabelConstraint
{
    if (self.placeholderLabelConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.placeholderLabelConstraints];
    }

    // 经过试验, textView.textContainerInset 默认为 {8, 0, 8, 0}. 然而实际上左右两边是有 5 点的距离的. 
    NSDictionary *views   = @{ @"placeholderLabel" : self.placeholderLabel };
    NSDictionary *metrics = @{ @"top"    : @(self.textContainerInset.top),
                               @"bottom" : @(self.textContainerInset.bottom),
                               @"left"   : @(self.textContainerInset.left + 5),
                               @"right"  : @(self.textContainerInset.right + 5), };

    NSMutableArray *constraints = [NSMutableArray new];
    {
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[placeholderLabel]-bottom-|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[placeholderLabel]-right-|"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];
    }
    [NSLayoutConstraint activateConstraints:constraints];

    self.placeholderLabelConstraints = constraints;
}

#pragma mark - 观察输入状态变化

- (void)dealloc
{
    [NSNotificationCenter lx_removeObserver:self.observer];
}

- (void)observeTextDidChange
{
    /** 手动设置 text 属性不会触发通知. */
    __weak __typeof(self) weakSelf = self;
    self.observer =
        [NSNotificationCenter lx_addObserverForName:UITextViewTextDidChangeNotification
                                             object:self
                                         usingBlock:^(NSNotification * _Nonnull note) {
                                             weakSelf.placeholderLabel.hidden = weakSelf.hasText;
                                         }];
}

@end