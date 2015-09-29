//
//  LXOriginalStatusCell.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXStatus.h"
#import "LXUtilities.h"
#import "UIImageView+WebCache.h"
#import "LXOriginalStatusCell.h"

static const CGFloat kLXImageSize = 76;
static const CGFloat kLXMargin    = 8;
static const CGFloat kLXImageRows = 3;

@interface LXOriginalStatusCell ()

@property (nonatomic, weak) IBOutlet UIImageView *avatarView;
@property (nonatomic, weak) IBOutlet UILabel     *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *vipView;
@property (nonatomic, weak) IBOutlet UILabel     *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel     *sourceLabel;
@property (nonatomic, weak) IBOutlet UITextView  *textView;

@property (nonatomic, strong) IBOutletCollection(UIImageView) NSArray *imageViews;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *imageContainerHeightConstraint;

@end

@implementation LXOriginalStatusCell

- (CGFloat)heightWithStatus:(LXStatus *)status inTableView:(UITableView *)tableView
{
    self.nameLabel.text   = status.user.name;
    self.timeLabel.text   = status.created_at;
    self.sourceLabel.text = status.source;
    self.textView.text    = status.text;

    NSUInteger row = ceil(status.pic_urls.count / kLXImageRows);
    self.imageContainerHeightConstraint.constant = row > 0 ? row * kLXImageSize + (row - 1) * kLXMargin : 0;

    CGSize size = { tableView.lx_width - 2 * kLXMargin, CGFLOAT_MAX };
    CGFloat textViewHeight    = [self.textView sizeThatFits:size].height;
    CGFloat contentViewHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    return textViewHeight + contentViewHeight + 1; // +1 是分隔线的高度.
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

    self.nameLabel.text   = user.name;
    self.timeLabel.text   = status.created_at;
    self.sourceLabel.text = status.source;
    self.textView.text    = status.text;
    
    NSUInteger count = status.pic_urls.count;
    NSUInteger row   = ceil(count / kLXImageRows);
    self.imageContainerHeightConstraint.constant = row > 0 ? row * kLXImageSize + (row - 1) * kLXMargin : 0;

    for (NSUInteger i = 0; i < count; ++i) {
        [self.imageViews[i] sd_setImageWithURL:[NSURL URLWithString:status.pic_urls[i].thumbnail_pic]
                              placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    }
}

@end