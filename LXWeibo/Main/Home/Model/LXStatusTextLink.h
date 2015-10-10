//
//  LXStatusTextLink.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/10.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import Foundation;

@interface LXStatusTextLink : NSObject

/** 特殊文字的内容. */
@property (nonatomic, copy) NSString *text;

/** 特殊文字的范围. */
@property (nonatomic, assign) NSRange range;

/** 特殊文字在 textView 上的所有 rect. */
@property (nonatomic, copy) NSArray<NSValue *> *rects;

@end