//
//  LXStatusTextPart.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/9.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface LXStatusTextPart : NSObject

/** 文字的内容. */
@property (nonatomic, copy) NSString *text;
/** 文字的范围. */
@property (nonatomic, assign) NSRange range;

/** 是否为特殊文字. */
@property (nonatomic, assign) BOOL isSpecial;
/** 是否为表情. */
@property (nonatomic, assign) BOOL isEmotion;

@end

NS_ASSUME_NONNULL_END