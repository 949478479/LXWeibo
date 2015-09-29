//
//  LXStatus.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;
#import "LXUser.h"
#import "LXPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXStatus : NSObject

/**	微博作者. */
@property (nonatomic, readonly, strong) LXUser *user;
/** 微博配图数组. */
@property (nonatomic, readonly, copy) NSArray<LXPhoto *> *pic_urls;
/**	字符串型的微博 @c ID. */
@property (nonatomic, readonly, copy) NSString *idstr;
/**	微博信息内容. */
@property (nonatomic, readonly, copy) NSString *text;
/**	微博创建时间. */
@property (nonatomic, readonly, copy) NSString *created_at;
/**	微博来源. */
@property (nonatomic, readonly, copy) NSString *source;

/** 被转发的微博. */
@property (nullable, nonatomic, readonly, strong) LXStatus *retweeted_status;

@end

NS_ASSUME_NONNULL_END