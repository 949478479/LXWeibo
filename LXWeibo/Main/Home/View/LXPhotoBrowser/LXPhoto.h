//
//  LXPhoto.h
//
//  Created by 从今以后 on 15/10/14.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@protocol LXPhoto <NSObject>
@property (nonatomic) UIImageView *sourceImageView;
@property (nullable, nonatomic) NSURL *originalImageURL;
@end

@interface LXPhoto : NSObject <LXPhoto>
@end

NS_ASSUME_NONNULL_END
