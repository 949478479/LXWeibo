//
//  LXEmotionsManager.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/7.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXEmotion.h"
#import "LXUtilities.h"
#import "MJExtension.h"
#import "LXEmotionsManager.h"

@implementation LXEmotionsManager

static NSArray<LXEmotion *> *sDefaultEmotionList      = nil;
static NSArray<LXEmotion *> *sEmojiEmotionList        = nil;
static NSArray<LXEmotion *> *sLXHEmotionList          = nil;
static NSMutableArray<LXEmotion *> *sRecentEmotions = nil;

static inline NSString * LXRecentEmotionsArchivePath()
{
    return [LXDocumentDirectory() stringByAppendingPathComponent:@"RecentEmotions.archive"];
}

+ (void)initialize
{
    sDefaultEmotionList = [LXEmotion objectArrayWithFilename:@"EmotionIcons/default/info.plist"];
    sEmojiEmotionList   = [LXEmotion objectArrayWithFilename:@"EmotionIcons/emoji/info.plist"];
    sLXHEmotionList     = [LXEmotion objectArrayWithFilename:@"EmotionIcons/lxh/info.plist"];
    sRecentEmotions   = [NSKeyedUnarchiver unarchiveObjectWithFile:LXRecentEmotionsArchivePath()];
    if (!sRecentEmotions) {
        sRecentEmotions = [NSMutableArray new];
    }

    // 程序进入后台时将最近表情数据写入沙盒.
    [NSNotificationCenter lx_addObserverForName:UIApplicationDidEnterBackgroundNotification
                                         object:nil
                                     usingBlock:
     ^(NSNotification * _Nonnull note) {
         [NSKeyedArchiver archiveRootObject:sRecentEmotions
                                     toFile:LXRecentEmotionsArchivePath()];
     }];
}

#pragma mark - *** 公共方法 ***

#pragma mark - 保存最近表情

+ (void)addEmotionToRecentList:(LXEmotion *)anEmotion
{
    // 如果该表情之前添加过,移除.
    for (LXEmotion *emotion in sRecentEmotions) {
        if ([emotion.chs isEqualToString:anEmotion.chs] || [emotion.code isEqualToString:anEmotion.code]) {
            [sRecentEmotions removeObject:emotion];
            break;
        }
    }

    // 将添加的表情插入到首位.
    [sRecentEmotions insertObject:anEmotion atIndex:0];
}

#pragma mark - 供应表情模型列表

+ (NSArray<LXEmotion *> *)recentEmotions
{
    return sRecentEmotions;
}

+ (NSArray<LXEmotion *> *)defaultEmotionList
{
    return sDefaultEmotionList;
}

+ (NSArray<LXEmotion *> *)emojiEmotionList
{
    return sEmojiEmotionList;
}

+ (NSArray<LXEmotion *> *)lxhEmotionList
{
    return sLXHEmotionList;
}

#pragma mark - 映射表情

+ (LXEmotion *)emotionWithCHS:(NSString *)chs
{
    NSAssert(chs.length, @"参数 chs 为 nil 或空字符串.");

    for (LXEmotion *emotion in sDefaultEmotionList) {
        if ([emotion.chs isEqualToString:chs]) {
            return emotion;
        }
    }

    for (LXEmotion *emotion in sLXHEmotionList) {
        if ([emotion.chs isEqualToString:chs]) {
            return emotion;
        }
    }

    return nil;
}

@end