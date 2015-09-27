//
//  LXOAuthInfoManager.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/27.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;
@class LXOAuthInfo;

NS_ASSUME_NONNULL_BEGIN

@interface LXOAuthInfoManager : NSObject

+ (void)saveOAuthInfo:(LXOAuthInfo *)OAuthInfo;

+ (nullable LXOAuthInfo *)OAuthInfo;

@end

NS_ASSUME_NONNULL_END