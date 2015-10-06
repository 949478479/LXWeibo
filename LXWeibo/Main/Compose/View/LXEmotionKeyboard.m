//
//  LXEmotionKeyboard.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/4.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXEmotion.h"
#import "LXUtilities.h"
#import "MJExtension.h"
#import "LXEmotionCell.h"
#import "LXPageControl.h"
#import "LXMagnifierView.h"
#import "LXEmotionKeyboard.h"

static const CGFloat kEmotionSize = 32;
static const NSUInteger kEmotionSectionCount = 4;
static const NSUInteger kEmotionCountPerPage = 20;
static const NSUInteger kEmotionCountPerRow  = 7;
static const NSUInteger kEmotionCountPerCol  = 3;

/** 表情类型,和表情分组按钮的 tag 绑定. */
typedef NS_ENUM(NSUInteger, LXEmotionType) {
    LXEmotionTypeRecently,
    LXEmotionTypeDefault,
    LXEmotionTypeEmoji,
    LXEmotionTypeLXH,
};

@interface LXEmotionKeyboard () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *selectedButton;
@property (nonatomic, weak) IBOutlet LXPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UICollectionView *emotionListView;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) LXMagnifierView *magnifierView;

@property (nonatomic, strong) NSArray<LXEmotion *> *defaultEmotionList;
@property (nonatomic, strong) NSArray<LXEmotion *> *emojiEmotionList;
@property (nonatomic, strong) NSArray<LXEmotion *> *lxhEmotionList;
@property (nonatomic, strong) NSMutableArray<LXEmotion *> *recentlyEmotionList;

@end

@implementation LXEmotionKeyboard

#pragma mark - 调整 cell 尺寸

- (void)awakeFromNib
{
    [super awakeFromNib];

    // 让 cell 和 emotionListView 一样大.
    self.flowLayout.itemSize = CGSizeMake(self.lx_width, self.emotionListView.lx_height);
}

#pragma mark - 注册重用标识符

- (void)registerNibWithEmotions:(NSArray<LXEmotion *> *)emotions emotionType:(LXEmotionType)emotionType
{
    // 该表情的表情页数.
    NSUInteger numberOfPages = (emotions.count + kEmotionCountPerPage - 1) / kEmotionCountPerPage;

    // 每一页即是一个 cell, 为其注册唯一的标识符.
    for (NSUInteger item = 0; item < numberOfPages; ++item) {
        [self.emotionListView registerClass:[LXEmotionCell class]
                 forCellWithReuseIdentifier:[self reuseIdentifierForItem:item inSection:emotionType]];
    }
}

- (NSString *)reuseIdentifierForItem:(NSInteger)item inSection:(NSInteger)section
{
    // 每个 cell 对应一个唯一的标识符,取消重用,实现懒加载,避免重复加载图片.
    return [NSString stringWithFormat:@"LXEmotionCell %ld-%ld", (long)section, (long)item];
}

#pragma mark - 加载表情

- (NSArray<LXEmotion *> *)emotionsWithType:(LXEmotionType)emotionType
{
    switch (emotionType) {
        case LXEmotionTypeRecently: return nil;

        case LXEmotionTypeDefault: {
            if (!self.defaultEmotionList) {
                self.defaultEmotionList =
                    [LXEmotion objectArrayWithFilename:@"EmotionIcons/default/info.plist"];

                [self registerNibWithEmotions:self.defaultEmotionList
                                  emotionType:LXEmotionTypeDefault];
            }
            return self.defaultEmotionList;
        }

        case LXEmotionTypeEmoji: {
            if (!self.emojiEmotionList) {
                self.emojiEmotionList =
                    [LXEmotion objectArrayWithFilename:@"EmotionIcons/emoji/info.plist"];

                [self registerNibWithEmotions:self.emojiEmotionList
                                  emotionType:LXEmotionTypeEmoji];
            }
            return self.emojiEmotionList;
        }

        case LXEmotionTypeLXH: {
            if (!self.lxhEmotionList) {
                self.lxhEmotionList =
                    [LXEmotion objectArrayWithFilename:@"EmotionIcons/lxh/info.plist"];

                [self registerNibWithEmotions:self.lxhEmotionList
                                  emotionType:LXEmotionTypeLXH];
            }
            return self.lxhEmotionList;
        }
    }
}

#pragma mark - 计算表情页数

- (NSUInteger)numberOfPagesForSection:(NSInteger)section
{
    NSUInteger numberOfEmotions = [self emotionsWithType:section].count;
    return (numberOfEmotions + kEmotionCountPerPage - 1) / kEmotionCountPerPage;
}

#pragma mark - 切换表情

- (IBAction)tabBarButtonDidTap:(UIButton *)sender
{
    // 禁用当前点击的按钮,解除之前按钮的禁用.
    sender.enabled = NO;
    self.selectedButton.enabled = YES;
    self.selectedButton = sender;

    [self.emotionListView reloadData]; // 刷新新分组的表情.

    [self.emotionListView scrollRectToVisible:self.bounds animated:NO]; // 滚动至第一页.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return kEmotionSectionCount; // 返回表情分组数.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    // 只显示当前选中的表情分组,其他分组返回 0, 从而不会显示.
    if (section == self.selectedButton.tag) {
        // 该分组的 cell 数量即表情页数.
        NSUInteger numberOfPages = [self numberOfPagesForSection:section];
        self.pageControl.countOfPages = numberOfPages;
        return numberOfPages;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 利用和 indexPath 绑定的 reuseIdentifier, 确保 cell 不会被重用,每个 cell 对应一个表情页.
    NSString *reuseIdentifier = [self reuseIdentifierForItem:indexPath.item
                                                   inSection:indexPath.section];

    LXEmotionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                    forIndexPath:indexPath];

    if (cell.emotions) { // 如果加载过了图片则直接返回,不要重复加载.
        return cell;
    }

    cell.emotionSize   = kEmotionSize;
    cell.emotionMatrix = (LXEmotionMatrix){ kEmotionCountPerRow, kEmotionCountPerCol };
    cell.magnifierView = self.magnifierView;

    // indexPath.row 为当前表情页的索引, range 即为当前表情页的表情的索引范围.
    NSRange range = { indexPath.row * kEmotionCountPerPage, kEmotionCountPerPage };

    // 获取当前表情分组对应的表情模型数组.
    NSArray<LXEmotion *> *emotions = [self emotionsWithType:indexPath.section];

    // 确保最后一页的表情不足一页时索引不会越界.
    if (range.location + kEmotionCountPerPage > emotions.count) {
        range.length = emotions.count - range.location;
    }

    // 让该表情页加载表情图片,也只加载这一次.
    cell.emotions = [emotions subarrayWithRange:range];
    
    return cell;
}

#pragma mark - PageControl 分页

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.percent =
        scrollView.contentOffset.x / (scrollView.contentSize.width - scrollView.lx_width);
}

#pragma mark - 加载放大镜

- (LXMagnifierView *)magnifierView
{
    if (!_magnifierView) {
        LXMagnifierView *magnifierView = [LXMagnifierView lx_instantiateFromNib];
        _magnifierView = magnifierView;
        [self addSubview:magnifierView];
    }
    return _magnifierView;
}

@end