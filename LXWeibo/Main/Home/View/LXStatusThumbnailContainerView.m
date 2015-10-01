//
//  LXStatusThumbnailContainerView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "XXNibBridge.h"
#import "LXStatusThumbnailView.h"
#import "LXStatusThumbnailContainerView.h"

@interface LXStatusThumbnailContainerView () <XXNibBridge>

@property (nonatomic, readwrite, weak) IBOutlet NSLayoutConstraint *heightConstraint;

@property (nonatomic, readwrite, strong) IBOutletCollection(LXStatusThumbnailView) NSArray *thumbnailViews;

@end

@implementation LXStatusThumbnailContainerView

- (void)hidenAndClearAllThumbnailViews
{
    for (LXStatusThumbnailView *thumbnailView in self.thumbnailViews) {
        thumbnailView.image  = nil;
        thumbnailView.hidden = YES;
    }
}

@end