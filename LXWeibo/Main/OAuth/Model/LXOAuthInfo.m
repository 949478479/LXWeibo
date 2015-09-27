//
//  LXOAuthInfo.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/27.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "MJExtension.h"
#import "LXOAuthInfo.h"

#pragma clang diagnostic ignored "-Wobjc-designated-initializers"

@implementation LXOAuthInfo

- (instancetype)init
{
    NSAssert(NO, @"必须使用指定构造器或者 OAuthInfoWithDictionary: 方法创建.");
    return nil;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _uid          = dict[@"uid"];
        _expires_in   = dict[@"expires_in"];
        _access_token = dict[@"access_token"];
        _created_time = [NSDate date];
    }
    return self;
}

+ (instancetype)OAuthInfoWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

MJCodingImplementation

@end