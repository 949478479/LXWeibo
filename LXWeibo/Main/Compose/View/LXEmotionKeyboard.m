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
#import "LXEmotionPageCell.h"
#import "LXPageControl.h"
#import "LXMagnifierView.h"
#import "LXEmotionKeyboard.h"
#import "LXRecentEmotionsManager.h"

NSString * const LXEmotionKeyboardDidSelectEmotionNotification = @"LXEmotionKeyboardDidSelectEmotionNotification";
NSString * const LXEmotionKeyboardDidDeleteEmotionNotification = @"LXEmotionKeyboardDidDeleteEmotionNotification";
NSString * const LXEmotionKeyboardSelectedEmotionUserInfoKey   = @"LXEmotionKeyboardSelectedEmotionUserInfoKey";

static const NSUInteger kEmotionCountPerPage = 20;

static NSString * const kReuseIdentifier = @"LXEmotionPageCell";

/** 表情类型,和表情分组按钮的 tag 绑定. */
typedef NS_ENUM(NSUInteger, LXEmotionType) {
    LXEmotionTypeRecently,
    LXEmotionTypeDefault,
    LXEmotionTypeEmoji,
    LXEmotionTypeLXH,
};

@interface LXEmotionKeyboard () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) LXMagnifierView *magnifierView;
@property (nonatomic, weak) IBOutlet LXPageControl *pageControl;
@property (nonatomic, weak) IBOutlet UIButton *selectedSectionButton;
@property (nonatomic, weak) IBOutlet UICollectionView *emotionListView;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSArray<LXEmotion *> *defaultEmotionList;
@property (nonatomic, strong) NSArray<LXEmotion *> *emojiEmotionList;
@property (nonatomic, strong) NSArray<LXEmotion *> *lxhEmotionList;
@property (nonatomic, strong) NSArray<LXEmotion *> *recentEmotionList;

@property (nonatomic, assign) LXEmotionType selectedEmotionType;

@end

@implementation LXEmotionKeyboard
@dynamic recentEmotionList;

#pragma mark - 初始配置

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.selectedEmotionType = LXEmotionTypeDefault;
    
    // 让 cell 和 emotionListView 一样大.
    self.flowLayout.itemSize = CGSizeMake(self.lx_width, self.emotionListView.lx_height);

    [self.emotionListView registerClass:[LXEmotionPageCell class]
             forCellWithReuseIdentifier:kReuseIdentifier];
}

#pragma mark - 加载表情

- (NSArray<LXEmotion *> *)recentEmotionList
{
    return [LXRecentEmotionsManager recentlyEmotions];
}

- (NSArray<LXEmotion *> *)defaultEmotionList
{
    if (!_defaultEmotionList) {
        _defaultEmotionList = [LXEmotion objectArrayWithFilename:@"EmotionIcons/default/info.plist"];
    }
    return _defaultEmotionList;
}

- (NSArray<LXEmotion *> *)emojiEmotionList
{
    if (!_emojiEmotionList) {
        _emojiEmotionList = [LXEmotion objectArrayWithFilename:@"EmotionIcons/emoji/info.plist"];
    }
    return _emojiEmotionList;
}

- (NSArray<LXEmotion *> *)lxhEmotionList
{
    if (!_lxhEmotionList) {
        _lxhEmotionList = [LXEmotion objectArrayWithFilename:@"EmotionIcons/lxh/info.plist"];
    }
    return _lxhEmotionList;
}

#pragma mark - 切换表情

- (IBAction)tabBarButtonDidTap:(UIButton *)sender
{
    // 禁用当前点击的按钮,解除之前按钮的禁用.
    sender.enabled = NO;
    self.selectedSectionButton.enabled = YES;
    self.selectedSectionButton = sender;
    self.selectedEmotionType = sender.tag;

    [self.emotionListView reloadData]; // 刷新新分组的表情.
    [self.emotionListView scrollRectToVisible:self.bounds animated:NO]; // 滚动至第一页.
}

#pragma mark - 计算表情页信息

- (NSArray<LXEmotion *> *)emotionListWithEmotionType:(LXEmotionType)type
{
    switch (type) {
        case LXEmotionTypeRecently: return self.recentEmotionList;
        case LXEmotionTypeDefault: return self.defaultEmotionList;
        case LXEmotionTypeEmoji: return self.emojiEmotionList;
        case LXEmotionTypeLXH: return self.lxhEmotionList;
    }
}

- (NSUInteger)numberOfPagesForEmotionType:(LXEmotionType)type
{
    NSUInteger numberOfEmotions = [self emotionListWithEmotionType:type].count;
    return (numberOfEmotions + kEmotionCountPerPage - 1) / kEmotionCountPerPage;
}

- (NSArray<LXEmotion *> *)subEmotionListForPage:(NSUInteger)page
{
    // indexPath.row 为当前表情页的索引, range 即为当前表情页的表情的索引范围.
    NSRange range = { page * kEmotionCountPerPage, kEmotionCountPerPage };

    // 获取当前表情分组对应的表情模型数组.
    NSArray<LXEmotion *> *emotions = [self emotionListWithEmotionType:self.selectedEmotionType];

    // 确保最后一页的表情不足一页时索引不会越界.
    if (range.location + kEmotionCountPerPage > emotions.count) {
        range.length = emotions.count - range.location;
    }

    return [emotions subarrayWithRange:range];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    NSUInteger numberOfPages = [self numberOfPagesForEmotionType:self.selectedEmotionType];

    self.pageControl.countOfPages = numberOfPages;

    return numberOfPages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LXEmotionPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kReuseIdentifier
                                                                        forIndexPath:indexPath];
    cell.magnifierView = self.magnifierView;
    cell.emotions = [self subEmotionListForPage:indexPath.row];

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

@interface LXEmotionKeyboardCollectionView : UICollectionView
@end
@implementation LXEmotionKeyboardCollectionView
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}
@end