//
//  LXRecentEmotionsManager.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/7.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXEmotion.h"
#import "LXUtilities.h"
#import "LXRecentEmotionsManager.h"

@implementation LXRecentEmotionsManager

static NSMutableArray<LXEmotion *> *sRecentlyEmotions = nil;

static inline NSString * LXRecentEmotionsArchivePath()
{
    return [LXDocumentDirectory() stringByAppendingPathComponent:@"RecentEmotions.archive"];
}

+ (void)initialize
{
    sRecentlyEmotions = [NSKeyedUnarchiver unarchiveObjectWithFile:LXRecentEmotionsArchivePath()];
    if (!sRecentlyEmotions) {
        sRecentlyEmotions = [NSMutableArray new];
    }

    // 程序进入后台时将最近表情数据写入沙盒.
    [NSNotificationCenter lx_addObserverForName:UIApplicationDidEnterBackgroundNotification
                                         object:nil
                                     usingBlock:
     ^(NSNotification * _Nonnull note) {
         [NSKeyedArchiver archiveRootObject:sRecentlyEmotions
                                     toFile:LXRecentEmotionsArchivePath()];
     }];
}

#pragma mark - *** 公共方法 ***

+ (void)addEmotion:(LXEmotion *)anEmotion
{
    // 如果该表情之前添加过,移除.
    for (LXEmotion *emotion in sRecentlyEmotions) {
        if ([emotion.chs isEqualToString:anEmotion.chs] || [emotion.code isEqualToString:anEmotion.code]) {
            [sRecentlyEmotions removeObject:emotion];
            break;
        }
    }

    // 将添加的表情插入到首位.
    [sRecentlyEmotions insertObject:anEmotion atIndex:0];
}

+ (NSArray<LXEmotion *> *)recentlyEmotions
{
    return sRecentlyEmotions;
}

@end