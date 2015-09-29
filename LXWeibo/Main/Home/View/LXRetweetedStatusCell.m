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
@property (nonatomic, weak) IBOutlet UITextView  *originalTextView;
@property (nonatomic, weak) IBOutlet UITextView  *retweetedTextView;

@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *imageViews;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageContainerHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *retweetContainerHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *retweetedTextViewBottomConstraint;

@end

@implementation LXRetweetedStatusCell

- (CGFloat)heightWithStatus:(LXStatus *)status inTableView:(UITableView *)tableView
{
    self.nameLabel.text         = status.user.name;
    self.timeLabel.text         = status.created_at;
    self.sourceLabel.text       = status.source;
    self.originalTextView.text  = status.text;
    self.retweetedTextView.text = status.retweeted_status.text;

    CGSize size = { tableView.lx_width - 2 * kLXMargin, CGFLOAT_MAX };
    CGFloat originalTextViewHeight  = [self.originalTextView sizeThatFits:size].height;
    CGFloat retweetedTextViewHeight = [self.retweetedTextView sizeThatFits:size].height;

    NSUInteger row = ceil(status.retweeted_status.pic_urls.count / kLXImageRows);
    CGFloat heightConstraintConstant = row > 0 ? row * kLXImageSize + (row - 1) * kLXMargin : 0;
    self.imageContainerHeightConstraint.constant   = heightConstraintConstant;
    self.retweetContainerHeightConstraint.constant =
        retweetedTextViewHeight + (row == 0 ? 0 : heightConstraintConstant + kLXMargin);

    CGFloat contentViewHeight =
        [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    return originalTextViewHeight + contentViewHeight + 1; // +1 是分隔线的高度.
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

    self.nameLabel.text         = user.name;
    self.timeLabel.text         = status.created_at;
    self.sourceLabel.text       = status.source;
    self.originalTextView.text  = status.text;
    self.retweetedTextView.text = retweetedStatus.text;

    NSUInteger count = status.retweeted_status.pic_urls.count;
    NSUInteger row   = ceil(count / kLXImageRows);

    CGFloat heightConstraintConstant = row > 0 ? row * kLXImageSize + (row - 1) * kLXMargin : 0;
    self.imageContainerHeightConstraint.constant = heightConstraintConstant;

    // 这里需要用 contentSize.height, 如果用 sizeThatFits: 方法获取的 height,
    // 个别情况下将造成 textView 高度不足而可小幅滚动.但是这样做出现过另一个 textView 高度被挤掉的问题而可以滚动的问题,
    // 不过之后就没再遇到,再遇到再说吧.
    CGFloat retweetedTextViewHeight = self.retweetedTextView.contentSize.height;
    if (row == 0) {
        self.retweetedTextViewBottomConstraint.constant = 0;
        self.retweetContainerHeightConstraint.constant  = retweetedTextViewHeight;
    } else {
        self.retweetedTextViewBottomConstraint.constant = kLXMargin;
        self.retweetContainerHeightConstraint.constant  = retweetedTextViewHeight + heightConstraintConstant + kLXMargin;
    }

    for (NSUInteger i = 0; i < count; ++i) {
        [self.imageViews[i] sd_setImageWithURL:[NSURL URLWithString:retweetedStatus.pic_urls[i].thumbnail_pic]
                              placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    }
}

@end