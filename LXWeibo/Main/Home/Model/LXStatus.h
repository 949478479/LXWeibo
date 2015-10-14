//
//  LXStatus.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
#import "LXUser.h"
#import "LXStatusPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXStatus : NSObject

/**	字符串型的微博 @c ID. */
@property (nonatomic, readonly, copy) NSString *idstr;

/**	微博作者. */
@property (nonatomic, readonly, strong) LXUser *user;
/**	微博创建时间. */
@property (nonatomic, readonly, copy) NSString *created_at;
/**	微博来源. */
@property (nonatomic, readonly, copy) NSString *source;
/**	微博信息内容. */
@property (nonatomic, readonly, copy) NSString *text;
/**	微博信息内容 (高亮显示特殊文字,显示表情). */
@property (nonatomic, readonly, copy) NSAttributedString *attributedText;
/** 微博配图数组. */
@property (nonatomic, readonly, copy) NSArray<LXStatusPhoto *> *pic_urls;

/** 是否是转发微博 */
@property (nonatomic, readonly, assign, getter=isRetweeted) BOOL retweeted;
/** 被转发的微博. */
@property (nullable, nonatomic, readonly, strong) LXStatus *retweeted_status;

/**	转发数. */
@property (nonatomic, readonly, assign) NSUInteger reposts_count;
/**	评论数. */
@property (nonatomic, readonly, assign) NSUInteger comments_count;
/**	表态数. */
@property (nonatomic, readonly, assign) NSUInteger attitudes_count;

@end

NS_ASSUME_NONNULL_END