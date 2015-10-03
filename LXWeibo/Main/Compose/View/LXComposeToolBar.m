//
//  LXComposeToolBar.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/3.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "XXNibBridge.h"
#import "LXComposeToolBar.h"

@interface LXComposeToolBar () <XXNibBridge>

@end

@implementation LXComposeToolBar

- (IBAction)toolBarButtonDidTap:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(composeToolBar:didTapButtonWithType:)]) {
        [self.delegate composeToolBar:self didTapButtonWithType:sender.tag];
    }
}

@end