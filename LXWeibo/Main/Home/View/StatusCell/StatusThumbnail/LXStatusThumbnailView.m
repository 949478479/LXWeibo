//
//  LXStatusThumbnailView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXStatusPhoto.h"
#import "LXUtilities.h"
#import "UIImageView+WebCache.h"
#import "LXStatusThumbnailView.h"

static UIImage *sGifLogoImage = nil;

@interface LXStatusThumbnailView ()

@property (nonatomic, strong) UIImageView *gifLogoView;

@end

@implementation LXStatusThumbnailView

#pragma mark - *** 公共方法 ***

- (void)setImageWithPhoto:(LXStatusPhoto *)photo placeholderImage:(UIImage *)placeholderImage
{
    _statusPhoto = photo;
    
    NSURL *url = [NSURL URLWithString:photo.thumbnail_pic];

    self.gifLogoView.hidden = ![url.pathExtension.lowercaseString isEqualToString:@"gif"];

    [self sd_setImageWithURL:url placeholderImage:placeholderImage];
}

- (void)setImage:(UIImage *)image
{
    self.hidden = !image;

    [super setImage:image];
}

#pragma mark - *** 私有方法 ***

#pragma mark - 缓存图片

+ (void)initialize
{
    [NSNotificationCenter lx_addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
                                         object:nil
                                     usingBlock:^(NSNotification * _Nonnull note) {
                                         sGifLogoImage = nil;
                                     }];
}

static inline UIImage * LXGifLogoImage()
{
    if (!sGifLogoImage) {
        sGifLogoImage = [UIImage imageNamed:@"timeline_image_gif"];
    }
    return sGifLogoImage;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self configureGifLogoView];
}

- (void)configureGifLogoView
{
    _gifLogoView = [[UIImageView alloc] initWithImage:LXGifLogoImage()];
    _gifLogoView.hidden = YES;
    _gifLogoView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:_gifLogoView];

    NSDictionary *views = NSDictionaryOfVariableBindings(_gifLogoView);
    NSString *visualFormats[] = { @"V:[_gifLogoView]-0-|", @"H:[_gifLogoView]-0-|" };
    for (NSUInteger i = 0; i < 2; ++i) {
        [NSLayoutConstraint activateConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:visualFormats[i]
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }
}

@end