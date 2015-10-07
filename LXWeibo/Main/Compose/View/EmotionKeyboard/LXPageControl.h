//
//  LXPageControl.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface LXPageControl : UIView

@property (nonatomic, assign) CGFloat percent;

@property (nonatomic, assign) IBInspectable BOOL hidesForSinglePage;

@property (nonatomic, assign) IBInspectable NSUInteger currentPage;
@property (nonatomic, assign) IBInspectable NSUInteger countOfPages;

@property (nullable, nonatomic, strong) IBInspectable UIColor *pagesColor;
@property (nullable, nonatomic, strong) IBInspectable UIColor *currentColor;

@end

NS_ASSUME_NONNULL_END