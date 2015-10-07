//
//  LXEmotion.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/4.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXEmotion : NSObject

/** 表情的文字描述. */
@property (nonatomic, readonly, copy) NSString *chs;
/** 表情的 png 图片名. */
@property (nonatomic, readonly, copy) NSString *png;

/** emoji 表情的 16 进制编码. */
@property (nullable, nonatomic, readonly, copy) NSString *code;
/** emoji 表情. */
@property (nullable, nonatomic, readonly, copy) NSString *emoji;

@end

NS_ASSUME_NONNULL_END