//
//  LXPlaceholderView.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXPlaceholderView.h"

@interface LXPlaceholderView ()

@property (nonatomic, readwrite, weak) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, readwrite, weak) IBOutlet UIImageView *iconView;

@end

@implementation LXPlaceholderView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // 让占位视图把点击事件漏给父视图,即输入框.这样点击到占位视图时也能正常激活第一响应者.
    return nil;
}

@end