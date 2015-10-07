//
//  LXRecentEmotionsManager.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/7.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;
@class LXEmotion;

NS_ASSUME_NONNULL_BEGIN

@interface LXRecentEmotionsManager : NSObject

+ (void)addEmotion:(LXEmotion *)emotion;

+ (NSArray<LXEmotion *> *)recentlyEmotions;

@end

NS_ASSUME_NONNULL_END