//
//  LXConst.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/7.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NSString * const LXVersionString = @"LXVersionString";

NSString * const LXAppKey = @"2547705806";
NSString * const LXAppSecret = @"9eede02b85f083f300041d776a8c5118";

NSString * const LXAuthorizeURL = @"https://api.weibo.com/oauth2/authorize?client_id=2547705806&redirect_uri=http://";
NSString * const LXAccessTokenURL = @"https://api.weibo.com/oauth2/access_token";

NSString * const LXUserInfoURL = @"https://api.weibo.com/2/users/show.json";
NSString * const LXHomeStatusURL = @"https://api.weibo.com/2/statuses/home_timeline.json";
NSString * const LXUnreadCountURL = @"https://rm.api.weibo.com/2/remind/unread_count.json";

NSString * const LXSendStatusWithImageURL = @"https://upload.api.weibo.com/2/statuses/upload.json";
NSString * const LXSendStatusWithoutImageURL = @"https://api.weibo.com/2/statuses/update.json";