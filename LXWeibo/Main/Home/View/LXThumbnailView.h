//
//  LXThumbnailView.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface LXThumbnailView : UIImageView

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage;

@end

NS_ASSUME_NONNULL_END