//
//  LXStatusAvatarView.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/1.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXUser;

NS_ASSUME_NONNULL_BEGIN

@interface LXStatusAvatarView : UIImageView

- (void)setImageWithUser:(LXUser *)user placeholderImage:(UIImage *)placeholderImage;

@end

NS_ASSUME_NONNULL_END