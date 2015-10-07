//
//  LXEmotion.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/4.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXEmotion.h"
#import "NSString+Emoji.h"
#import "NSObject+MJCoding.h"

@implementation LXEmotion

- (NSString *)emoji
{
    if (_code) {
        return [NSString emojiWithStringCode:_code];
    }
    return nil;
}

+ (NSArray *)ignoredCodingPropertyNames
{
    return @[@"emoji"]; // 这个属性是为了方便转换 emoji 表情用的,不要归档,否则会崩溃.
}

MJExtensionCodingImplementation

@end