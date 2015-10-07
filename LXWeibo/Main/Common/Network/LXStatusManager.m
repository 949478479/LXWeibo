//
//  LXStatusManager.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/7.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXConst.h"
#import "LXStatus.h"
#import "MJExtension.h"
#import "LXUtilities.h"
#import "AFNetworking.h"
#import "LXStatusManager.h"
#import "LXOAuthInfoManager.h"

@implementation LXStatusManager

+ (AFHTTPRequestOperationManager *)manager
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 10;
    return manager;
}

#pragma mark - 授权

+ (void)requestAccessTokenWithAuthorizationCode:(NSString *)code
                                     completion:(void (^)(LXOAuthInfo * _Nonnull))completion
                                        failure:(void (^)(NSError * _Nonnull))failure
{
    NSAssert(code.length, @"code 为 nil 或空字符串.");
    NSAssert(completion, @"参数 completion 为 nil.");

    LXLog(@"正在授权...");

    NSDictionary *parameters = @{ @"client_id"     : LXAppKey,
                                  @"client_secret" : LXAppSecret,
                                  @"grant_type"    : @"authorization_code",
                                  @"code"          : code,
                                  @"redirect_uri"  : @"http://", };

    [[LXStatusManager manager] POST:LXAccessTokenURL
                         parameters:parameters
                            success:
     ^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {

         LXLog(@"授权成功");

         LXOAuthInfo *OAuthInfo = [LXOAuthInfo OAuthInfoWithDictionary:responseObject];
         [LXOAuthInfoManager saveOAuthInfo:OAuthInfo];
         completion(OAuthInfo);

     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

         LXLog(@"授权出错 \n%@", error);
         if (failure) {
             failure(error);
         }
     }];
}

#pragma mark - 更新用户信息

+ (void)updateUserInfoWithCompletion:(void (^)(LXOAuthInfo * _Nonnull))completion
                             failure:(void (^)(NSError * _Nonnull))failure
{
    NSAssert(completion, @"参数 completion 为 nil.");

    LXOAuthInfo *OAuthInfo = [LXOAuthInfoManager OAuthInfo];

    NSDictionary *parameters = @{ @"uid"          : OAuthInfo.uid,
                                  @"access_token" : OAuthInfo.access_token, };

    [[LXStatusManager manager] GET:LXUserInfoURL
                        parameters:parameters
                           success:
     ^(AFHTTPRequestOperation * _Nonnull operation, NSDictionary * _Nonnull responseObject) {

         LXLog(@"加载用户昵称请求完成!");

         NSString *name = responseObject[@"name"];
         NSAssert(name, @"返回 JSON 中获取的 name 为 nil.");

         completion(OAuthInfo);

         if (![OAuthInfo.name isEqualToString:name]) {
             [OAuthInfo setValue:name forKey:@"name"];
             [LXOAuthInfoManager saveOAuthInfo:OAuthInfo];
         }
     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {

         LXLog(@"加载用户昵称请求出错\n%@", error);
         if (failure) {
             failure(error);
         }
     }];
}

#pragma mark - 获取未读数

+ (void)loadUnreadStatusCountWithCompletion:(void (^)(NSString * _Nullable))completion
                                    failure:(void (^)(NSError * _Nonnull))failure
{
    NSAssert(completion, @"参数 completion 为 nil.");

    LXOAuthInfo *OAuthInfo = [LXOAuthInfoManager OAuthInfo];

    NSDictionary *parameters = @{ @"uid"          : OAuthInfo.uid,
                                  @"access_token" : OAuthInfo.access_token, };

    [[LXStatusManager manager] GET:LXUnreadCountURL
                        parameters:parameters
                           success:
     ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

         NSString *unreadCount = [responseObject[@"status"] description];

         LXLog(@"获取未读数完成! %@", unreadCount);

         if ([unreadCount isEqualToString:@"0"]) {
             unreadCount = nil;
         }

         completion(unreadCount);

     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {

         LXLog(@"获取未读数出错\n%@", error);
         if (failure) {
             failure(error);
         }
     }];
}

#pragma mark - 加载微博

+ (void)loadNewStatusesSinceStatusID:(NSString *)statusID
                          completion:(void (^)(NSArray<LXStatus *> * _Nonnull))completion
                             failure:(void (^)(NSError * _Nonnull))failure
{
    NSAssert(completion, @"参数 completion 为 nil.");

    NSDictionary *parameters = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                                  @"since_id"     : statusID ?: @"0", };

    [[LXStatusManager manager] GET:LXHomeStatusURL
                        parameters:parameters
                           success:
     ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

         LXLog(@"加载最新微博请求完成!");

         NSArray *statusDictionaries = responseObject[@"statuses"];

         if (statusDictionaries.count == 0) {
             completion(@[]);
             return;
         }

         NSMutableArray *statuses = [LXStatus objectArrayWithKeyValuesArray:statusDictionaries];

         completion(statuses);

     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {

         LXLog(@"加载最新微博请求出错\n%@", error);
         if (failure) {
             failure(error);
         }
     }];
}

+ (void)loadMoreStatusesAfterStatusID:(NSString *)statusID
                           completion:(void (^)(NSArray<LXStatus *> *))completion
                              failure:(void (^)(NSError *))failure
{
    NSAssert(statusID, @"参数 maxID 为 nil.");
    NSAssert(completion, @"参数 completion 为 nil.");

    NSDictionary *parameters = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                                  @"max_id"       : @(statusID.longLongValue - 1), };

    [[LXStatusManager manager] GET:LXHomeStatusURL
                        parameters:parameters
                           success:
     ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {

         LXLog(@"加载更多微博请求完成!");

         NSArray *statusDictionaries  = responseObject[@"statuses"];
         NSMutableArray *statuses = [LXStatus objectArrayWithKeyValuesArray:statusDictionaries];
         completion(statuses);

     } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {

         LXLog(@"加载更多微博请求出错\n%@", error);
         if (failure) {
             failure(error);
         }
     }];
}

#pragma mark - 发送微博

+ (void)sendStatus:(NSString *)status
        completion:(void (^)(void))completion
           failure:(void (^)(NSError * _Nonnull))failure
{
    NSAssert(status.length, @"参数 status 为 nil 或空字符串.");
    NSAssert(completion, @"参数 completion 为 nil.");

    NSDictionary *params = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                              @"status"       : status, };

    [[LXStatusManager manager] POST:LXSendStatusWithoutImageURL
                         parameters:params
                            success:
     ^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {

         LXLog(@"文字微博发表成功!");
         completion();

     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

         LXLog(@"文字微博发表失败!\n%@", error);
         if (failure) {
             failure(error);
         }
     }];
}

+ (void)sendStatus:(NSString *)status
             image:(UIImage *)image
        completion:(void (^)(void))completion
           failure:(void (^)(NSError * _Nonnull))failure
{
    NSAssert(image, @"参数 image 为 nil.");
    NSAssert(completion, @"参数 completion 为 nil.");

    NSDictionary *params = @{ @"access_token" : [LXOAuthInfoManager OAuthInfo].access_token,
                              @"status"       : status, };

    [[LXStatusManager manager] POST:LXSendStatusWithImageURL
                         parameters:params
          constructingBodyWithBlock: ^(id<AFMultipartFormData>  _Nonnull formData) {

              NSData *data = UIImageJPEGRepresentation(image, 0);
              [formData appendPartWithFileData:data name:@"pic" fileName:@"xxx.jpg" mimeType:@"image/jpeg"];

          } success: ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              
              LXLog(@"图片微博发表成功!");
              completion();
              
          } failure: ^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
              
              LXLog(@"图片微博发表失败!\n%@", error);
              if (failure) {
                  failure(error);
              }
          }];
}

@end