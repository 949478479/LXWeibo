//
//  LXThumbnailContainerView.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
#import "LXThumbnailView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXThumbnailContainerView : UIView

@property (nonatomic, readonly, weak) NSLayoutConstraint *heightConstraint;

@property (nonatomic, readonly, strong) NSArray<LXThumbnailView *> *thumbnailViews;

- (void)hidenAndClearAllThumbnailViews;

@end

NS_ASSUME_NONNULL_END