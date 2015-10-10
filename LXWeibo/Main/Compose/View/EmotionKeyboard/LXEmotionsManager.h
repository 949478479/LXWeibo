//
//  LXEmotionsManager.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/7.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;
#import "LXEmotion.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXEmotionsManager : NSObject

+ (void)addEmotionToRecentList:(LXEmotion *)emotion;

+ (NSArray<LXEmotion *> *)recentEmotions;
+ (NSArray<LXEmotion *> *)defaultEmotionList;
+ (NSArray<LXEmotion *> *)emojiEmotionList;
+ (NSArray<LXEmotion *> *)lxhEmotionList;

+ (LXEmotion *)emotionWithCHS:(NSString *)chs;

@end

NS_ASSUME_NONNULL_END