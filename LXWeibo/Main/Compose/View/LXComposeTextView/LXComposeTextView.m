//
//  LXComposeTextView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/2.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "LXUtilities.h"
#import "LXComposeTextView.h"
#import "LXStatusThumbnailContainerView.h"

@interface LXComposeTextView () 

@property (nonatomic, weak) id observer;

@property (nonatomic, assign) CGSize textContentSize;

@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) NSArray<NSLayoutConstraint *> *placeholderLabelConstraints;

@property (nonatomic, strong) LXStatusThumbnailContainerView *thumbnailContainerView;
@property (nonatomic, strong) NSLayoutConstraint *thumbnailContainerViewTopConstraint;

@end

@implementation LXComposeTextView

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

    // 手动设置 attributedText 属性不会触发通知,而且会改变文本内容和字体.
    self.placeholderLabel.font   = self.font;
    self.placeholderLabel.hidden = self.hasText;
}

- (void)setContentSize:(CGSize)contentSize
{
    /* UITextView 自己调用此方法时, contentSize.height 就是文本区域的实际高度,在此基础上加上
     thumbnailContainerView 的高度和 8 点底部间距求得滚动范围. 文本内容行数变化,字体变化,均会触发此方法,因此 
     thumbnailContainerView 位置会得到实时更新.在这里保存最新的文本高度,图片行数变化时利用该高度调用此方法.从而
     不改变 thumbnailContainerViewTopConstraint 的值而只增大 contentSize.height, 为增加的照片行增加滚动范围. */
    self.textContentSize = contentSize;
    self.thumbnailContainerViewTopConstraint.constant = contentSize.height;

    // 有配图时才有必要额外增加 8 点 contentSize.height 作为底部间距.
    CGFloat heightConstraint = self.thumbnailContainerView.heightConstraint.constant;
    if (heightConstraint > 0) {
        contentSize.height += heightConstraint + self.layoutMargins.bottom;
    }

    [super setContentSize:contentSize];
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
    const CGFloat kMargin = 5;
    NSDictionary *views   = @{ @"placeholderLabel" : self.placeholderLabel };
    NSDictionary *metrics = @{ @"top"  : @(self.textContainerInset.top),
                               @"left" : @(self.textContainerInset.left + kMargin), };

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

        // 通过宽度约束限制 placeholderLabel 的宽度,而不是靠左右的间距约束.
        [constraints addObject:
         [NSLayoutConstraint constraintWithItem:self.placeholderLabel
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self
                                      attribute:NSLayoutAttributeWidth
                                     multiplier:1
                                       constant:-(self.textContainerInset.left + kMargin +
                                                  self.textContainerInset.right + kMargin)]];
    }
    [NSLayoutConstraint activateConstraints:constraints];

    self.placeholderLabelConstraints = constraints;
}

#pragma mark - 安装缩略图容器

- (void)configureThumbnailContainerView
{
    self.thumbnailContainerView = [LXStatusThumbnailContainerView lx_instantiateFromNib];

    [self addSubview:self.thumbnailContainerView];

    [self updateThumbnailContainerViewConstraint];
}

- (void)updateThumbnailContainerViewConstraint
{
    // 设置图片容器与顶部的距离为文本区域高度,该高度即为 contentSize.height, 亦可通过下面这个式子计算所得.
    CGFloat constant = ceil(self.font.lineHeight +
                            self.textContainerInset.top +
                            self.textContainerInset.bottom);

    self.thumbnailContainerViewTopConstraint =
        [NSLayoutConstraint constraintWithItem:self.thumbnailContainerView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1
                                      constant:constant];
    self.thumbnailContainerViewTopConstraint.active = YES;

    // 水平居中.
    [NSLayoutConstraint constraintWithItem:self.thumbnailContainerView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1
                                  constant:0].active = YES;

    // 宽度为 textView 宽度减去两侧各 8 点间距.
    [NSLayoutConstraint constraintWithItem:self.thumbnailContainerView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeWidth
                                multiplier:1
                                  constant:-(self.layoutMargins.left + self.layoutMargins.right)].active = YES;

    // 一开始没有图片,将高度设置为 0.
    self.thumbnailContainerView.heightConstraint.constant = 0;
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
         }];
}

#pragma mark - *** 公共方法 ***

- (void)addImage:(UIImage *)image
{
    // 只是简单地挨个添加图片,没做太多细节处理.
    CGFloat imageSize = (self.thumbnailContainerView.lx_width - 2 * kLXStatusThumbnailMargin)
        / kLXStatusThumbnailRows;

    [self.thumbnailContainerView.thumbnailViews enumerateObjectsUsingBlock:
     ^(LXStatusThumbnailView * _Nonnull imageView, NSUInteger idx, BOOL * _Nonnull stop) {
         if (!imageView.image) {
             imageView.image = image;

             NSUInteger rows = ceil((idx + 1) / kLXStatusThumbnailRows);
             CGFloat height  = rows * imageSize + (rows - 1) * kLXStatusThumbnailMargin;
             if (self.thumbnailContainerView.heightConstraint.constant != height) {
                 self.thumbnailContainerView.heightConstraint.constant = height;
                 self.contentSize = self.textContentSize; // 更新 contentSize.
             }

             *stop = YES;
         }
    }];
}

- (NSArray<UIImage *> *)images
{
    NSMutableArray *images = [NSMutableArray new];
    for (UIImageView *imageView in self.thumbnailContainerView.thumbnailViews) {
        UIImage *image = imageView.image;
        if (image) {
            [images addObject:image];
        } else {
            return images;
        }
    }
    return images;
}

@end