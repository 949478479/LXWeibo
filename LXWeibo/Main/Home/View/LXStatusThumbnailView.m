//
//  LXStatusThumbnailView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXPhoto.h"
#import "UIImageView+WebCache.h"
#import "LXStatusThumbnailView.h"

@interface LXStatusThumbnailView ()

@property (nonatomic, readwrite, strong) UIImageView *gifLogoView;

@end

@implementation LXStatusThumbnailView

#pragma mark - *** 公共方法 ***

- (void)setImageWithPhoto:(LXPhoto *)photo placeholderImage:(UIImage *)placeholderImage
{
    self.hidden = NO;

    NSURL *url = [NSURL URLWithString:photo.thumbnail_pic];

    self.gifLogoView.hidden = ![url.pathExtension.lowercaseString isEqualToString:@"gif"];

    [self sd_setImageWithURL:url placeholderImage:placeholderImage];
}

#pragma mark - *** 私有方法 ***

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self configureGifLogoView];
}

- (void)configureGifLogoView
{
    _gifLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeline_image_gif"]];

    _gifLogoView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:_gifLogoView];

    NSDictionary *views = NSDictionaryOfVariableBindings(_gifLogoView);

    [NSLayoutConstraint activateConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_gifLogoView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [NSLayoutConstraint activateConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_gifLogoView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
}

@end