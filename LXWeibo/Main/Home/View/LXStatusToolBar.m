//
//  LXStatusToolBar.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXStatus.h"
#import "LXStatusToolBar.h"
#import "LXUtilities.h"
#import "XXNibBridge.h"

static const NSUInteger kLXCountLimit = 10000;

@interface LXStatusToolBar () <XXNibBridge>

@property (nonatomic, weak) IBOutlet UIButton *repostsButton;
@property (nonatomic, weak) IBOutlet UIButton *commentsButton;
@property (nonatomic, weak) IBOutlet UIButton *attitudesButton;

@end

@implementation LXStatusToolBar

#pragma mark - *** 公共方法 ***

- (void)configureWithStatus:(LXStatus *)status
{
    self.repostsButton.lx_normalTitle   = [self formatButtonTitleWithNumber:status.reposts_count] ?: @"转发";
    self.commentsButton.lx_normalTitle  = [self formatButtonTitleWithNumber:status.reposts_count] ?: @"评论";
    self.attitudesButton.lx_normalTitle = [self formatButtonTitleWithNumber:status.reposts_count] ?: @"赞";
}

#pragma mark - *** 私有方法 ***

- (NSString *)formatButtonTitleWithNumber:(NSUInteger)number
{
    NSString *title = nil;

    // 超过限额则显示为 "xxx.xx 万" 形式.
    if (number >= kLXCountLimit) {
        float decimalNumber = (float)number / kLXCountLimit;
        // 小数部分不为 0,则显示两位小数.否则显示整数.
        if (decimalNumber - (int)decimalNumber != 0) {
            title = [NSString stringWithFormat:@"%.2f万", decimalNumber];
        } else {
            title = [NSString stringWithFormat:@"%d万", (int)decimalNumber];
        }
    } else if (number > 0) {
        title = [NSString stringWithFormat:@"%lu", (unsigned long)number];
    }

    return title;
}

@end