//
//  LXEmotion.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/4.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXEmotion.h"
#import "NSString+Emoji.h"

@implementation LXEmotion

- (NSString *)emoji
{
    return [NSString emojiWithStringCode:self.code];
}

@end