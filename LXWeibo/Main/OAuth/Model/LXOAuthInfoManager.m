//
//  LXOAuthInfoManager.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/27.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXOAuthInfo.h"
#import "LXOAuthInfoManager.h"

@implementation LXOAuthInfoManager

static inline NSString * LXOAuthInfoArchivePath()
{
    return [LXDocumentDirectory() stringByAppendingPathComponent:@"OAuthInfo.archive"];
}

+ (void)saveOAuthInfo:(LXOAuthInfo *)OAuthInfo
{
    [NSKeyedArchiver archiveRootObject:OAuthInfo toFile:LXOAuthInfoArchivePath()];
}

+ (LXOAuthInfo *)OAuthInfo
{
    LXOAuthInfo *OAuthInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:LXOAuthInfoArchivePath()];

    NSDate *now = [NSDate date];

    NSDate *expires = [OAuthInfo.created_time dateByAddingTimeInterval:
                       [OAuthInfo.expires_in unsignedLongLongValue]];

    if ([expires compare:now] != NSOrderedDescending) {
        return nil;
    }

    return OAuthInfo;
}

@end