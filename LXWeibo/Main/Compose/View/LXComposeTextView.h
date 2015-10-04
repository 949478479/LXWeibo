//
//  LXTextView.h
//  LXWeibo
//
//  Created by 从今以后 on 15/10/2.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface LXComposeTextView : UITextView

@property (nonatomic, copy)   IBInspectable NSString *placeholder;
@property (nonatomic, strong) IBInspectable UIColor  *placeholderColor;

@end

NS_ASSUME_NONNULL_END