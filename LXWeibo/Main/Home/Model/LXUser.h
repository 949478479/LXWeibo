//
//  LXUser.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXUser : NSObject

/**	字符串型的用户 UID. */
@property (nonatomic, readonly, copy) NSString *idstr;
/**	友好显示名称. */
@property (nonatomic, readonly, copy) NSString *name;
/**	用户头像地址, 50×50 像素. */
@property (nonatomic, readonly, copy) NSString *profile_image_url;
/** 会员类型.大于 2 代表是会员. */
@property (nonatomic, readonly, assign) NSUInteger mbtype;
/** 会员等级. */
@property (nonatomic, readonly, assign) NSUInteger mbrank;
/** 是否是会员. */
@property (nonatomic, readonly, assign, getter=isVip) BOOL vip;

@end

NS_ASSUME_NONNULL_END