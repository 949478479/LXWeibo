//
//  LXThumbnailContainerView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/30.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "XXNibBridge.h"
#import "LXThumbnailView.h"
#import "LXThumbnailContainerView.h"

@interface LXThumbnailContainerView () <XXNibBridge>

@property (nonatomic, readwrite, weak) IBOutlet NSLayoutConstraint *heightConstraint;

@property (nonatomic, readwrite, strong) IBOutletCollection(LXThumbnailView) NSArray *thumbnailViews;

@end

@implementation LXThumbnailContainerView

- (void)hidenAndClearAllThumbnailViews
{
    for (LXThumbnailView *thumbnailView in self.thumbnailViews) {
        thumbnailView.image  = nil;
        thumbnailView.hidden = YES;
    }
}

@end