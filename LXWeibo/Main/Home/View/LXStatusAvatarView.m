//
//  LXStatusAvatarView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/1.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUser.h"
#import "LXStatusAvatarView.h"
#import "UIImageView+WebCache.h"

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
            image = [UIImage imageNamed:@"avatar_vip"];
            break;

        case LXUserVerifiedGrassroot:
            image = [UIImage imageNamed:@"avatar_grassroot"];
            break;

        case LXUserVerifiedOrgMedia:
        case LXUserVerifiedOrgWebsite:
        case LXUserVerifiedOrgEnterprice:
            image = [UIImage imageNamed:@"avatar_enterprise_vip"];
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

    [NSLayoutConstraint activateConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_verifiedLogoView(17)]-(-8)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [NSLayoutConstraint activateConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_verifiedLogoView(17)]-(-8)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
}

@end