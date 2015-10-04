//
//  LXTextView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "LXComposeTextView.h"
#import "LXUtilities.h"
#import "LXStatusThumbnailContainerView.h"

@interface LXTextView () 

@property (nonatomic, weak) id observer;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *placeholderLabelConstraints;
@property (nonatomic, strong) LXStatusThumbnailContainerView *thumbnailContainerView;
@property (nonatomic, strong) NSLayoutConstraint *thumbnailContainerViewTopConstraint;

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

    [self configureThumbnailContainerView];
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

    // 经过试验, textView.textContainerInset 默认为 {8, 0, 8, 0}. 然而实际上左右两边是各有 5 点的距离的.
    NSDictionary *views   = @{ @"placeholderLabel" : self.placeholderLabel };
    NSDictionary *metrics = @{ @"top"    : @(self.textContainerInset.top),
                               @"left"   : @(self.textContainerInset.left + 5), };

    NSMutableArray *constraints = [NSMutableArray new];
    {
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[placeholderLabel]"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];

        /* 由于 UITextView 继承自 UIScrollView, 因此不能把两边间距都给约束,这将导致占位文字很长时只显示 1 行,
         且 textView 可以水平滚动. */
        [constraints addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[placeholderLabel]"
                                                 options:0
                                                 metrics:metrics
                                                   views:views]];

        // 通过宽度约束限制 placeholderLabel 的宽度,而不是靠左右的间距约束.(不知道 VFL 如何创建这种约束.)
        [constraints addObject:
         [NSLayoutConstraint constraintWithItem:self.placeholderLabel
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeWidth
                                     multiplier:1
                                       constant:-(self.textContainerInset.left + 5 +
                                                  self.textContainerInset.right + 5)]];
    }
    [NSLayoutConstraint activateConstraints:constraints];

    self.placeholderLabelConstraints = constraints;
}

#pragma mark - 安装缩略图容器

- (void)configureThumbnailContainerView
{
    self.thumbnailContainerView = [LXStatusThumbnailContainerView lx_instantiateFromNib];
    [self addSubview:self.thumbnailContainerView];

    self.thumbnailContainerView.backgroundColor = [UIColor lx_randomColor];

    [NSLayoutConstraint constraintWithItem:self.thumbnailContainerView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                  constant:0].active = YES;

    [NSLayoutConstraint constraintWithItem:self.thumbnailContainerView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1
                                  constant:-16].active = YES;

    self.thumbnailContainerViewTopConstraint =
        [NSLayoutConstraint constraintWithItem:self.thumbnailContainerView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self//.placeholderLabel
                                     attribute:NSLayoutAttributeTop//NSLayoutAttributeBottom
                                    multiplier:1
                                      constant:self.font.lineHeight + 8 + 8];
    self.thumbnailContainerViewTopConstraint.active = YES;
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
                                         usingBlock:
         ^(NSNotification * _Nonnull note) {
             weakSelf.placeholderLabel.hidden = weakSelf.hasText;

             CGFloat topConstraint = weakSelf.thumbnailContainerViewTopConstraint.constant;
             CGFloat contentHeight = weakSelf.contentSize.height;
             if (topConstraint != contentHeight) {
                 weakSelf.thumbnailContainerViewTopConstraint.constant = contentHeight;
             }
             LXLogSize(weakSelf.contentSize);
         }];
}

@end