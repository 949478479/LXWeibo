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
@property (nonatomic, weak) IBOutlet UITextView *subTextView;
@property (nonatomic, weak) IBOutlet UITextView *mainTextView;
@property (nonatomic, weak) IBOutlet UIImageView *vipView;
@property (nonatomic, weak) IBOutlet LXStatusToolBar *toolBar;
@property (nonatomic, weak) IBOutlet LXStatusAvatarView *avatarView;

@property (nonatomic, weak) IBOutlet UIView *statusContainerView;

@property (nonatomic, weak) IBOutlet LXStatusThumbnailContainerView *thumbnailContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *statusContainerTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mainTextLabelBottomConstraint;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *subTextViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mainTextViewHeightConstraint;

@property (nonatomic, assign) CGFloat imageSize;

@end

@implementation LXStatusCell

static UIColor *sVipNameColor = nil;
static UIColor *sNoVipNameColor = nil;

static UIImage *sPlaceholderImage = nil;
static UIImage *sAvatarDefaultImage = nil;

static UIColor *sOriginalStatusBackgroundColor = nil;
static UIColor *sRetweetedStatusBackgroundColor = nil;

static CGFloat kMaxWidth;

#pragma mark - *** 私有方法 ***

#pragma mark - 缓存 UIImage 和 UIColor

+ (void)initialize
{
    kMaxWidth = LXScreenSize().width - 2 * kLXStatusThumbnailMargin;

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

    UIEdgeInsets textContainerInset  = UIEdgeInsetsMake(0, -5, 0, -5);
    _subTextView.textContainerInset  = textContainerInset;
    _mainTextView.textContainerInset = textContainerInset;

    self.imageSize = (kMaxWidth - 2 * kLXStatusThumbnailMargin) / kLXStatusThumbnailRows;
}

#pragma mark - 根据配图行数调整高度约束

- (void)adjustConstraintForImageRows:(NSUInteger)row andIsOriginalStatus:(BOOL)isOriginal
{
    if (row > 0) {
        // 有配图时将 mainTextLabel 和 thumbnailContainerView 的间距约束调整回 kLXMargin.
        _mainTextLabelBottomConstraint.constant = kLXStatusThumbnailMargin;
        // 调整 thumbnailContainerView 的高度约束.每行配图高 kLXImageSize, 行之间间距为 kLXMargin.即最多 3 行 2 间距.
        _thumbnailContainerView.heightConstraint.constant = row * _imageSize + (row - 1) * kLXStatusThumbnailMargin;
    } else {
        // 无配图时将 thumbnailContainerView 高度约束设置为 0, mainTextLabel 与 thumbnailContainerView
        // 的间距约束应调整为 0, 否则和父视图的底部距离就是 2 * kLXMargin 而不是 kLXMargin.
        _mainTextLabelBottomConstraint.constant = 0;
        _thumbnailContainerView.heightConstraint.constant = 0;
    }

    // 是原创微博时将顶部和 subTextLabel 间的约束调整为 0, 因为 subTextLabel 此时高度近乎为 0.
    _statusContainerTopConstraint.constant = isOriginal ? -8 : kLXStatusThumbnailMargin;
}

#pragma mark - 设置 cell 内容

- (void)setupLabelContentAndAdjustConstraintWithStatus:(LXStatus *)status
{
    LXStatus *retweetedStatus = status.retweeted_status;

    // 有标识符说明不是模板 cell, 设置显示文本.模板 cell 计算行高的时候没必要设置这些单行 label 的内容.
    if (self.reuseIdentifier) {
        
        _nameLabel.text   = status.user.name;
        _timeLabel.text   = status.created_at;
        _sourceLabel.text = status.source;

        if (retweetedStatus) { // 这是转发微博.
            _subTextView.attributedText = status.attributedText;
            _mainTextView.attributedText = retweetedStatus.attributedText;
        } else { // 这是原创微博.
            _subTextView.attributedText = nil;
            _mainTextView.attributedText = status.attributedText;
        }
    }

    CGSize boundingSize = { kMaxWidth, CGFLOAT_MAX };

    if (retweetedStatus) { // 这是转发微博.

        _subTextViewHeightConstraint.constant =
            [status.attributedText lx_sizeWithBoundingSize:boundingSize].height;

        _mainTextViewHeightConstraint.constant =
            [retweetedStatus.attributedText lx_sizeWithBoundingSize:boundingSize].height;

        [self adjustConstraintForImageRows:ceil(status.retweeted_status.pic_urls.count / kLXStatusThumbnailRows)
                       andIsOriginalStatus:NO];
    }
    else { // 这是原创微博.

        _subTextViewHeightConstraint.constant = 0;
        _mainTextViewHeightConstraint.constant =
            [status.attributedText lx_sizeWithBoundingSize:boundingSize].height;

        [self adjustConstraintForImageRows:ceil(status.pic_urls.count / kLXStatusThumbnailRows)
                       andIsOriginalStatus:YES];
    }
}

- (void)setupBackgroundColorForIsOriginalStatus:(BOOL)isOriginal
{
    if (isOriginal) {
        _mainTextView.backgroundColor = sOriginalStatusBackgroundColor;
        _statusContainerView.backgroundColor = sOriginalStatusBackgroundColor;
    } else {
        _mainTextView.backgroundColor = sRetweetedStatusBackgroundColor; // UILabel 的背景色清空拖性能.
        _statusContainerView.backgroundColor = sRetweetedStatusBackgroundColor;
    }
}

- (void)setupStatusBasicInfoWithStatus:(LXStatus *)status
{
     LXUser *user = status.user;

    [_avatarView setImageWithUser:user placeholderImage:LXAvatarDefaultImage()];

    // 根据是否是 vip 设置 nameLabel 的字体颜色,决定是否显示 vip 图标,并设置对应具体等级的图标.
    if (user.isVip) {
        NSUInteger mbrank = user.mbrank;
        NSString *imageName = [NSString stringWithFormat:@"common_icon_membership_level%lu",
                               (unsigned long)mbrank];

        _vipView.image       = [UIImage imageNamed:imageName];
        _vipView.hidden      = NO;
        _nameLabel.textColor = sVipNameColor;

    } else {
        _vipView.hidden      = YES;
        _nameLabel.textColor = sNoVipNameColor;
    }
}

- (void)setupThumbnailWithPhotos:(NSArray<LXStatusPhoto *> *)photos
{
    NSUInteger picCount = photos.count;
    for (NSUInteger i = 0; i < picCount; ++i) {
        LXStatusThumbnailView *thumbnailView = _thumbnailContainerView.thumbnailViews[i];
        [thumbnailView setImageWithPhoto:photos[i]
                        placeholderImage:LXPlaceholderImage()];
    }
}

#pragma mark - 清空配图并隐藏

- (void)prepareForReuse
{
    [super prepareForReuse];

    [_thumbnailContainerView hidenAndClearAllThumbnailViews];
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
