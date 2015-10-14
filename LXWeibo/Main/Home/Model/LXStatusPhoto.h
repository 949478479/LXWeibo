//
//  LXStatusPhoto.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXStatusPhoto : NSObject

/** 缩略图地址 */
@property (nonatomic, readonly, copy) NSString *thumbnail_pic;

/**	中等图片地址,没有时不返回此字段. */
@property (nullable, nonatomic, readonly, copy) NSString *bmiddle_pic;

/**	原始图片地址,没有时不返回此字段. */
@property (nullable, nonatomic, readonly, copy) NSString *original_pic;

@end

NS_ASSUME_NONNULL_END