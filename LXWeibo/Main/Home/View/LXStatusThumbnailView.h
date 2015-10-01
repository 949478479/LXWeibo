//
//  LXStatusThumbnailView.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXPhoto;

NS_ASSUME_NONNULL_BEGIN

@interface LXStatusThumbnailView : UIImageView

- (void)setImageWithPhoto:(LXPhoto *)photo placeholderImage:(UIImage *)placeholderImage;

@end

NS_ASSUME_NONNULL_END