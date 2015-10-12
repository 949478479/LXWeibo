//
//  LXStatusManager.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/7.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;
@class LXStatus, LXOAuthInfo;

NS_ASSUME_NONNULL_BEGIN

@interface LXStatusManager : NSObject

+ (void)clearStatusCache;
+ (uint64_t)statusCacheSize;

///------------------------------------------------------------------------------------------------
/// @name 授权
///------------------------------------------------------------------------------------------------

+ (void)requestAccessTokenWithAuthorizationCode:(NSString *)code
                                     completion:(void (^)(LXOAuthInfo *OAuthInfo))completion
                                        failure:(nullable void (^)(NSError *error))failure;

///------------------------------------------------------------------------------------------------
/// @name 更新用户信息
///------------------------------------------------------------------------------------------------

+ (void)updateUserInfoWithCompletion:(void (^)(LXOAuthInfo *OAuthInfo))completion
                             failure:(nullable void (^)(NSError *error))failure;

///------------------------------------------------------------------------------------------------
/// @name 读取微博信息
///------------------------------------------------------------------------------------------------

+ (void)loadUnreadStatusCountWithCompletion:(void (^)(NSString * _Nullable unreadCount))completion
                                    failure:(nullable void (^)(NSError *error))failure;

+ (void)loadNewStatusesSinceStatusID:(nullable NSString *)statusID
                          completion:(void (^)(NSArray<LXStatus *> *statuses))completion
                             failure:(nullable void (^)(NSError *error))failure;

+ (void)loadMoreStatusesAfterStatusID:(NSString *)statusID
                           completion:(void (^)(NSArray<LXStatus *> *statuses))completion
                              failure:(nullable void (^)(NSError *error))failure;

///------------------------------------------------------------------------------------------------
/// @name 发表微博
///------------------------------------------------------------------------------------------------

+ (void)sendStatus:(NSString *)status
        completion:(void (^)(void))completion
           failure:(nullable void (^)(NSError *error))failure;

+ (void)sendStatus:(nullable NSString *)status
             image:(UIImage *)image
        completion:(void (^)(void))completion
           failure:(nullable void (^)(NSError *error))failure;
@end

NS_ASSUME_NONNULL_END