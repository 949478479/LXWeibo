//
//  LXPhotoBrowerCell.h
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;
@protocol LXPhoto;

NS_ASSUME_NONNULL_BEGIN

@interface LXPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, readonly, weak) UIImageView  *imageView;
@property (nonatomic, readonly, weak) UIScrollView *scrollView;

- (void)configureWithPhoto:(id<LXPhoto>)photo completion:(nullable void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END