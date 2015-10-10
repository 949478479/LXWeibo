//
//  LXStatusCell.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXStatus.h"
#import "LXUtilities.h"
#import "LXStatusCell.h"
#import "LXStatusToolBar.h"
#import "LXStatusAvatarView.h"
#import "LXStatusThumbnailContainerView.h"

@interface LXStatusCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *sourceLabel;
@property (nonatomic, weak) IBOutlet UILabel *subTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *mainTextLabel;
@property (nonatomic, weak) IBOutlet UIImageView *vipView;
@property (nonatomic, weak) IBOutlet LXStatusToolBar *toolBar;
@property (nonatomic, weak) IBOutlet LXStatusAvatarView *avatarView;

@property (nonatomic, weak) IBOutlet UIView *statusContainerView;

@property (nonatomic, weak) IBOutlet LXStatusThumbnailContainerView *thumbnailContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *statusContainerTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mainTextLabelBottomConstraint;

@property (nonatomic, assign) CGFloat imageSize;

@end

@implementation LXStatusCell

static UIColor *sVipNameColor = nil;
static UIColor *sNoVipNameColor = nil;

static UIImage *sPlaceholderImage = nil;
static UIImage *sAvatarDefaultImage = nil;

static UIColor *sOriginalStatusBackgroundColor = nil;
static UIColor *sRetweetedStatusBackgroundColor = nil;

#pragma mark - *** 私有方法 ***

+ (void)initialize
{
    sVipNameColor = [UIColor orangeColor];
    sNoVipNameColor = [UIColor blackColor];

    sAvatarDefaultImage = [UIImage imageNamed:@"avatar_default"];
    sPlaceholderImage = [UIImage imageNamed:@"timeline_image_placeholder"];

    sOriginalStatusBackgroundColor = [UIColor whiteColor];
    sRetweetedStatusBackgroundColor = [UIColor lx_colorWithHexString:@"F5F5F5"];

    [NSNotificationCenter lx_addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                         object:nil
                                     usingBlock:^(NSNotification * _Nonnull note) {
                                         sPlaceholderImage   = nil;
                                         sAvatarDefaultImage = nil;
                                     }];
}

static inline UIImage * LXAvatarDefaultImage()
{
    if (!sAvatarDefaultImage) {
        sAvatarDefaultImage = [UIImage imageNamed:@"avatar_default"];
    }
    return sAvatarDefaultImage;
}

static inline UIImage * LXPlaceholderImage()
{
    if (!sPlaceholderImage) {
        sPlaceholderImage = [UIImage imageNamed:@"timeline_image_placeholder"];
    }
    return sPlaceholderImage;
}

#pragma mark - 设置 label 最大宽度

- (void)awakeFromNib
{
    [super awakeFromNib];

    CGFloat maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 2 * kLXStatusThumbnailMargin;

    self.subTextLabel.preferredMaxLayoutWidth  = maxWidth;
    self.mainTextLabel.preferredMaxLayoutWidth = maxWidth;

    self.imageSize = (maxWidth - 2 * kLXStatusThumbnailMargin) / kLXStatusThumbnailRows;
}

#pragma mark - 根据配图行数调整高度约束

- (void)adjustConstraintForImageRows:(NSUInteger)row andIsOriginalStatus:(BOOL)isOriginal
{
    if (row > 0) {
        // 有配图时将 mainTextLabel 和 thumbnailContainerView 的间距约束调整回 kLXMargin.
        self.mainTextLabelBottomConstraint.constant = kLXStatusThumbnailMargin;
        // 调整 thumbnailContainerView 的高度约束.每行配图高 kLXImageSize, 行之间间距为 kLXMargin.即最多 3 行 2 间距.
        self.thumbnailContainerView.heightConstraint.constant = row * self.imageSize + (row - 1) * kLXStatusThumbnailMargin;
    } else {
        // 无配图时将 thumbnailContainerView 高度约束设置为 0, mainTextLabel 与 thumbnailContainerView
        // 的间距约束应调整为 0, 否则和父视图的底部距离就是 2 * kLXMargin 而不是 kLXMargin.
        self.mainTextLabelBottomConstraint.constant = 0;
        self.thumbnailContainerView.heightConstraint.constant = 0;
    }

    // 是原创微博时将顶部和 subTextLabel 间的约束调整为 0, 因为 subTextLabel 此时高度近乎为 0.
    self.statusContainerTopConstraint.constant = isOriginal ? -8 : kLXStatusThumbnailMargin;
}

#pragma mark - 设置 cell 内容

- (void)setupLabelContentAndAdjustConstraintWithStatus:(LXStatus *)status
{
    // 有标识符说明不是模板 cell, 设置显示文本.模板 cell 计算行高的时候没必要设置这些单行 label 的内容.
    if (self.reuseIdentifier) {
        self.nameLabel.text   = status.user.name;
        self.timeLabel.text   = status.created_at;
        self.sourceLabel.text = status.source;
    }

    LXStatus *retweetedStatus = status.retweeted_status;

    if (retweetedStatus) { // 这是转发微博.
        self.subTextLabel.attributedText  = status.attributedText;
        self.mainTextLabel.attributedText = retweetedStatus.attributedText;

        [self adjustConstraintForImageRows:ceil(status.retweeted_status.pic_urls.count / kLXStatusThumbnailRows)
                       andIsOriginalStatus:NO];
    }
    else { // 这是原创微博.
        self.subTextLabel.attributedText  = nil;
        self.mainTextLabel.attributedText = status.attributedText;

        [self adjustConstraintForImageRows:ceil(status.pic_urls.count / kLXStatusThumbnailRows)
                       andIsOriginalStatus:YES];
    }
}

- (void)setupBackgroundColorForIsOriginalStatus:(BOOL)isOriginal
{
    if (isOriginal) {
        self.mainTextLabel.backgroundColor = sOriginalStatusBackgroundColor;
        self.statusContainerView.backgroundColor = sOriginalStatusBackgroundColor;
    } else {
        self.mainTextLabel.backgroundColor = sRetweetedStatusBackgroundColor; // UILabel 的背景色清空拖性能.
        self.statusContainerView.backgroundColor = sRetweetedStatusBackgroundColor;
    }
}

- (void)setupStatusBasicInfoWithStatus:(LXStatus *)status
{
     LXUser *user = status.user;

    [self.avatarView setImageWithUser:user placeholderImage:LXAvatarDefaultImage()];

    // 根据是否是 vip 设置 nameLabel 的字体颜色,决定是否显示 vip 图标,并设置对应具体等级的图标.
    if (user.isVip) {

        NSUInteger mbrank = user.mbrank;
        NSAssert(mbrank >= 1 && mbrank <= 6, @"会员等级不正确 %lu", mbrank);
        NSString *imageName = [NSString stringWithFormat:@"common_icon_membership_level%lu",
                               (unsigned long)mbrank];

        self.vipView.image       = [UIImage imageNamed:imageName];
        self.vipView.hidden      = NO;
        self.nameLabel.textColor = sVipNameColor;

    } else {
        self.vipView.hidden      = YES;
        self.nameLabel.textColor = sNoVipNameColor;
    }
}

- (void)setupThumbnailWithPhotos:(NSArray<LXPhoto *> *)photos
{
    NSUInteger picCount = photos.count;
    for (NSUInteger i = 0; i < picCount; ++i) {
        LXStatusThumbnailView *thumbnailView = self.thumbnailContainerView.thumbnailViews[i];
        [thumbnailView setImageWithPhoto:photos[i]
                        placeholderImage:LXPlaceholderImage()];
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

- (CGFloat)rowHeightWithStatus:(LXStatus *)status inTableView:(UITableView *)tableView
{
    [self setupLabelContentAndAdjustConstraintWithStatus:status];

    // 无分隔线,不用 +1 了.
    return [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

#pragma mark - 配置 cell 的展示数据

- (void)configureWithStatus:(LXStatus *)status
{
    [self setupStatusBasicInfoWithStatus:status];

    [self setupLabelContentAndAdjustConstraintWithStatus:status];

    LXStatus *retweetedStatus = status.retweeted_status;

    [self setupBackgroundColorForIsOriginalStatus:!retweetedStatus];

    [self setupThumbnailWithPhotos:retweetedStatus ? retweetedStatus.pic_urls : status.pic_urls];

    [self.toolBar configureWithStatus:status];
}

@end