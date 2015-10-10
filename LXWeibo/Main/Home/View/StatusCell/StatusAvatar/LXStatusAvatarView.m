//
//  LXStatusAvatarView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/1.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUser.h"
#import "LXUtilities.h"
#import "LXStatusAvatarView.h"
#import "UIImageView+WebCache.h"

static UIImage *sPersonalVerifiedImage   = nil;
static UIImage *sGrassrootVerifiedImage  = nil;
static UIImage *sEnterpriseVerifiedImage = nil;

@interface LXStatusAvatarView ()

@property (nonatomic, strong) UIImageView *verifiedLogoView;

@end

@implementation LXStatusAvatarView

#pragma mark - *** 公共方法 ***

- (void)setImageWithUser:(LXUser *)user placeholderImage:(UIImage *)placeholderImage
{
    UIImage *image = nil;

    switch (user.verified_type) {
        case LXUserVerifiedTypePersonal:
            image = LXPersonalVerifiedImage();
            break;

        case LXUserVerifiedGrassroot:
            image = LXGrassrootVerifiedImage();
            break;

        case LXUserVerifiedOrgMedia:
        case LXUserVerifiedOrgWebsite:
        case LXUserVerifiedOrgEnterprice:
            image = LXEnterpriseVerifiedImage();
            break;

        default:
            break;
    }

    self.verifiedLogoView.image  = image;
    self.verifiedLogoView.hidden = !image;

    [self sd_setImageWithURL:[NSURL URLWithString:user.profile_image_url]
            placeholderImage:placeholderImage];
}

#pragma mark - *** 私有方法 ***

#pragma mark - 缓存图片

+ (void)initialize
{
    [NSNotificationCenter lx_addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                         object:nil
                                     usingBlock:^(NSNotification * _Nonnull note) {
                                         sPersonalVerifiedImage   = nil;
                                         sGrassrootVerifiedImage  = nil;
                                         sEnterpriseVerifiedImage = nil;
                                     }];
}

static inline UIImage * LXPersonalVerifiedImage()
{
    if (!sPersonalVerifiedImage) {
        sPersonalVerifiedImage = [UIImage imageNamed:@"avatar_vip"];
    }
    return sPersonalVerifiedImage;
}

static inline UIImage * LXGrassrootVerifiedImage()
{
    if (!sGrassrootVerifiedImage) {
        sGrassrootVerifiedImage = [UIImage imageNamed:@"avatar_grassroot"];
    }
    return sGrassrootVerifiedImage;
}

static inline UIImage * LXEnterpriseVerifiedImage()
{
    if (!sEnterpriseVerifiedImage) {
        sEnterpriseVerifiedImage = [UIImage imageNamed:@"avatar_enterprise_vip"];
    }
    return sEnterpriseVerifiedImage;
}

#pragma mark - 配置等级 logo

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self configureVerifiedLogoView];
}

- (void)configureVerifiedLogoView
{
    _verifiedLogoView = [UIImageView new];

    _verifiedLogoView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:_verifiedLogoView];

    NSDictionary *views = NSDictionaryOfVariableBindings(_verifiedLogoView);
    NSString *visualFormats[] = { @"V:[_verifiedLogoView(17)]-(-8)-|", @"H:[_verifiedLogoView(17)]-(-8)-|" };
    for (NSUInteger i = 0; i < 2; ++i) {
        [NSLayoutConstraint activateConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }
}

@end