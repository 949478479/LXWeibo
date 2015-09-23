//
//  UIButton+LXExtension.h
//
//  Created by 从今以后 on 15/9/21.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (LXExtension)

@property (nullable, nonatomic, copy) NSString *lx_normalTitle;
@property (nullable, nonatomic, copy) NSString *lx_selectedTitle;
@property (nullable, nonatomic, copy) NSString *lx_disabledTitle;
@property (nullable, nonatomic, copy) NSString *lx_highlightedTitle;

@end

NS_ASSUME_NONNULL_END