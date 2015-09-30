//
//  LXRetweetedStatusCell.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXStatus.h"
#import "LXToolBar.h"
#import "LXUtilities.h"
#import "UIImageView+WebCache.h"
#import "LXRetweetedStatusCell.h"
#import "LXThumbnailContainerView.h"

/** 配图尺寸. */
static const CGFloat kLXImageSize = 76;
/** 子视图间的间距. */
static const CGFloat kLXMargin = 8;
/** 配图行数. */
static const CGFloat kLXImageRows = 3;

@interface LXRetweetedStatusCell ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UIImageView *vipView;
@property (nonatomic, weak) IBOutlet UILabel     *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel     *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel     *sourceLabel;
@property (nonatomic, weak) IBOutlet UILabel     *originalLabel;
@property (nonatomic, weak) IBOutlet UILabel     *retweetedLabel;
@property (nonatomic, weak) IBOutlet LXToolBar   *toolBar;

@property (nonatomic, weak) IBOutlet LXThumbnailContainerView *thumbnailContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *retweetedLabelBottomConstraint;

@end

@implementation LXRetweetedStatusCell

#pragma mark - *** 私有方法 ***

#pragma mark - 设置 label 最大宽度

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.thumbnailContainerView.backgroundColor = self.retweetedLabel.backgroundColor;

    CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 2 * kLXMargin;
    self.originalLabel.preferredMaxLayoutWidth  = maxWidth;
    self.retweetedLabel.preferredMaxLayoutWidth = maxWidth;
}

#pragma mark - 根据配图行数调整高度约束

- (void)adjustConstraintForImageRows:(NSUInteger)row
{
    if (row > 0) {
        // 有配图时将 retweetedLabel 和 imageView 容器顶部的间距约束调整回 kLXMargin.
        self.retweetedLabelBottomConstraint.constant = kLXMargin;
        // 调整 imageView 容器高度约束.每行配图高 kLXImageSize, 行之间间距为 kLXMargin.即最多 3 行 2 间距.
        self.thumbnailContainerView.heightConstraint.constant = row * kLXImageSize + (row - 1) * kLXMargin;
    } else {
        // 无配图时将 imageView 容器高度约束设置为 0, 由于此时 imageView 容器消失, retweetedLabel
        // 与 imageView 容器的间距约束应调整为 0, 否则和父视图的底部距离就是 2 * kLXMargin 而不是 kLXMargin.
        self.retweetedLabelBottomConstraint.constant = 0;
        self.thumbnailContainerView.heightConstraint.constant = 0;
    }
}

#pragma mark - 清空配图并隐藏

- (void)prepareForReuse
{
    [super prepareForReuse];

    [self.thumbnailContainerView hidenAndClearAllThumbnailViews];
}

#pragma mark - *** 公共方法 ***

#pragma mark - 根据约束计算行高

- (CGFloat)heightWithStatus:(LXStatus *)status inTableView:(UITableView *)tableView
{
    self.nameLabel.text      = status.user.name;
    self.timeLabel.text      = status.created_at;
    self.sourceLabel.text    = status.source;
    self.originalLabel.text  = status.text;

    LXStatus *retweetedStatus = status.retweeted_status;
    self.retweetedLabel.text = [NSString stringWithFormat:@"@%@:%@",
                                retweetedStatus.user.name, retweetedStatus.text];

    [self adjustConstraintForImageRows:ceil(status.retweeted_status.pic_urls.count / kLXImageRows)];

    // 无分隔线,不用 +1 了.
    return [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

#pragma mark - 配置 cell 的展示数据

- (void)configureWithStatus:(LXStatus *)status
{
    LXUser *user = status.user;

    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:user.profile_image_url]
                       placeholderImage:[UIImage imageNamed:@"avatar_default"]];

    // 根据是否是 vip 设置 nameLabel 的字体颜色,决定是否显示 vip 图标,并设置对应具体等级的图标.
    if (user.isVip) {

        NSUInteger mbrank = user.mbrank;
        NSAssert(mbrank >= 1 && mbrank <= 6, @"会员等级不正确 %lu", mbrank);
        NSString *imageName = [NSString stringWithFormat:@"common_icon_membership_level%lu",
                               (unsigned long)mbrank];

        self.vipView.image       = [UIImage imageNamed:imageName];
        self.vipView.hidden      = NO;
        self.nameLabel.textColor = [UIColor orangeColor];

    } else {
        self.vipView.hidden      = YES;
        self.nameLabel.textColor = [UIColor blackColor];
    }

    LXStatus *retweetedStatus = status.retweeted_status;

    self.nameLabel.text      = user.name;
    self.timeLabel.text      = status.created_at;
    self.sourceLabel.text    = status.source;
    self.originalLabel.text  = status.text;
    self.retweetedLabel.text = [NSString stringWithFormat:@"@%@:%@",
                                retweetedStatus.user.name, retweetedStatus.text];

    NSUInteger picCount = status.retweeted_status.pic_urls.count;

    // 调整约束,使之匹配 cell 此时的高度.
    [self adjustConstraintForImageRows:ceil(picCount / kLXImageRows)];

    for (NSUInteger i = 0; i < picCount; ++i) {
        LXThumbnailView *thumbnailView = self.thumbnailContainerView.thumbnailViews[i];
        [thumbnailView setImageWithURL:[NSURL URLWithString:retweetedStatus.pic_urls[i].thumbnail_pic]
                      placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    }

    [self.toolBar configureWithStatus:status];
}

@end