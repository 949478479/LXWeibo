//
//  LXStatusThumbnailContainerView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "XXNibBridge.h"
#import "LXStatusPhoto.h"
#import "LXStatusThumbnailView.h"
#import "LXPhotoBrowserController.h"
#import "LXStatusThumbnailContainerView.h"

const CGFloat kLXStatusThumbnailRows   = 3;
const CGFloat kLXStatusThumbnailMargin = 8;

@interface LXStatusThumbnailContainerView () <XXNibBridge>

@property (nonatomic, readwrite, weak) IBOutlet NSLayoutConstraint *heightConstraint;

@property (nonatomic, readwrite, strong) IBOutletCollection(LXStatusThumbnailView) NSArray *thumbnailViews;

@end

@implementation LXStatusThumbnailContainerView

#pragma mark - 公共方法

- (void)hidenAndClearAllThumbnailViews
{
    for (LXStatusThumbnailView *thumbnailView in self.thumbnailViews) {
        thumbnailView.image = nil;
    }
}

#pragma mark - 点击事件处理

- (IBAction)tapGestureRecognizer:(UITapGestureRecognizer *)sender
{
    CGPoint touchPoint = [sender locationInView:self];

    [_thumbnailViews enumerateObjectsUsingBlock:^(LXStatusThumbnailView * _Nonnull obj,
                                                  NSUInteger idx,
                                                  BOOL * _Nonnull stop) {
        // 找出被点击且有图的 LXStatusThumbnailView.
        if (!obj.image || !CGRectContainsPoint(obj.frame, touchPoint)) {
            return ;
        }

        // 弹出图片浏览器.
        LXPhotoBrowserController *photoBrower = [LXPhotoBrowserController photoBrower];
        photoBrower.currentPhotoIndex = idx;
        photoBrower.photos = [_thumbnailViews lx_map:^id _Nullable(LXStatusThumbnailView * _Nonnull obj,
                                                                   BOOL * _Nonnull stop) {
            UIImage *image = obj.image;

            // 遍历到无图的 imageView, 那么之后的也都没有图了.
            if (!image) {
                *stop = YES;
                return nil;
            }

            LXPhoto *photo = [LXPhoto new];
            photo.sourceImageView  = obj;
            photo.originalImageURL = [NSURL URLWithString:obj.statusPhoto.original_pic ?: obj.statusPhoto.bmiddle_pic];

            return photo;
        }];

        [LXTopViewController() presentViewController:photoBrower animated:YES completion:nil];

        *stop = YES;
    }];
}

@end