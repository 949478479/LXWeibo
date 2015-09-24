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
@property (nullable, nonatomic, copy) NSString *lx_disabledTitle;
@property (nullable, nonatomic, copy) NSString *lx_selectedTitle;
@property (nullable, nonatomic, copy) NSString *lx_highlightedTitle;

@property (nullable, nonatomic, strong) UIImage *lx_normalImage;
@property (nullable, nonatomic, strong) UIImage *lx_disabledImage;
@property (nullable, nonatomic, strong) UIImage *lx_selectedImage;
@property (nullable, nonatomic, strong) UIImage *lx_highlightedImage;

@property (nullable, nonatomic, strong) UIImage *lx_normalBackgroundImage;
@property (nullable, nonatomic, strong) UIImage *lx_disabledBackgroundImage;
@property (nullable, nonatomic, strong) UIImage *lx_selectedBackgroundImage;
@property (nullable, nonatomic, strong) UIImage *lx_highlightedBackgroundImage;

@end

NS_ASSUME_NONNULL_END