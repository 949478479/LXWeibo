//
//  LXOAuthInfo.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/27.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXOAuthInfo : NSObject <NSCoding>

/** access_token 的生命周期,单位是秒数. */
@property (nonatomic, readonly, strong) NSNumber *expires_in;
/** access_token 的创建时间. */
@property (nonatomic, readonly, strong) NSDate   *created_time;
/** 当前授权用户的 UID. */
@property (nonatomic, readonly, copy)   NSString *uid;
/** access_token . */
@property (nonatomic, readonly, copy)   NSString *access_token;
/** 用户昵称. */
@property (nonatomic, readonly, copy)   NSString *name;

- (instancetype)initWithDictionary:(NSDictionary *)dict NS_DESIGNATED_INITIALIZER;

+ (instancetype)OAuthInfoWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END