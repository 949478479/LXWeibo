//
//  LXStatusThumbnailView.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXStatusPhoto;

NS_ASSUME_NONNULL_BEGIN

@interface LXStatusThumbnailView : UIImageView

@property (nonatomic, readonly, strong) LXStatusPhoto *statusPhoto;

- (void)setImageWithPhoto:(LXStatusPhoto *)photo placeholderImage:(UIImage *)placeholderImage;

@end

NS_ASSUME_NONNULL_END