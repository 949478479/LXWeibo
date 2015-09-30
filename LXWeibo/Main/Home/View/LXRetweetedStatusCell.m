//
//  LXRetweetedStatusCell.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXStatus.h"
#import "LXUtilities.h"
#import "UIImageView+WebCache.h"
#import "LXRetweetedStatusCell.h"

static const CGFloat kLXImageSize = 76;
static const CGFloat kLXMargin    = 8;
static const CGFloat kLXImageRows = 3;

@interface LXRetweetedStatusCell ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel     *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *vipView;
@property (nonatomic, weak) IBOutlet UILabel     *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel     *sourceLabel;
@property (nonatomic, weak) IBOutlet UILabel     *originalLabel;
@property (nonatomic, weak) IBOutlet UILabel     *retweetedLabel;

@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *imageViews;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageContainerHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *retweetedLabelBottomConstraint;

@end

@implementation LXRetweetedStatusCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.originalLabel.preferredMaxLayoutWidth  = maxWidth;
    self.retweetedLabel.preferredMaxLayoutWidth = maxWidth;
}

- (void)adjustConstraintForImageRows:(NSUInteger)row
{
    if (row > 0) {
        self.retweetedLabelBottomConstraint.constant = kLXMargin;
        self.imageContainerHeightConstraint.constant   = row * kLXImageSize + (row - 1) * kLXMargin;
    } else {
        self.retweetedLabelBottomConstraint.constant = 0;
        self.imageContainerHeightConstraint.constant = 0;
    }
}

- (CGFloat)heightWithStatus:(LXStatus *)status inTableView:(UITableView *)tableView
{
    self.nameLabel.text      = status.user.name;
    self.timeLabel.text      = status.created_at;
    self.sourceLabel.text    = status.source;
    self.originalLabel.text  = status.text;
    self.retweetedLabel.text = status.retweeted_status.text;

    [self adjustConstraintForImageRows:ceil(status.retweeted_status.pic_urls.count / kLXImageRows)];

    // 无分隔线,不用 +1 了.
    return [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (void)configureWithStatus:(LXStatus *)status
{
    LXUser *user = status.user;

    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:user.profile_image_url]
                       placeholderImage:[UIImage imageNamed:@"avatar_default"]];

    if (user.isVip) {
        NSUInteger mbrank = user.mbrank;
        NSAssert(mbrank >= 1 && mbrank <= 6, @"会员等级不正确 %lu", mbrank);
        NSString *imageName = [NSString stringWithFormat:@"common_icon_membership_level%lu", (unsigned long)mbrank];
        self.vipView.image  = [UIImage imageNamed:imageName];

        self.vipView.hidden = NO;
        self.nameLabel.textColor = [UIColor orangeColor];
    } else {
        self.vipView.hidden = YES;
        self.nameLabel.textColor = [UIColor blackColor];
    }

    LXStatus *retweetedStatus = status.retweeted_status;

    self.nameLabel.text      = user.name;
    self.timeLabel.text      = status.created_at;
    self.sourceLabel.text    = status.source;
    self.originalLabel.text  = status.text;
    self.retweetedLabel.text = retweetedStatus.text;

    NSUInteger count = status.retweeted_status.pic_urls.count;

    [self adjustConstraintForImageRows:ceil(count / kLXImageRows)];

    for (NSUInteger i = 0; i < count; ++i) {
        [self.imageViews[i] sd_setImageWithURL:[NSURL URLWithString:retweetedStatus.pic_urls[i].thumbnail_pic]
                              placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    }
}

@end