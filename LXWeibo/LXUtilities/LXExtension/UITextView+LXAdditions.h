//
//  UITextView+LXAdditions.h
//
//  Created by 从今以后 on 15/10/6.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (LXAdditions)

/**
 *  插入表情图片到当前光标位置.图片高度和字体行高一致,宽度根据纵横比得出.
 *
 *  @warning 此方法会将 @c [UITextView attributedText] 的字体改为 @c [UITextView font] 的字体.
 */
- (void)lx_insertEmotionAttributedStringWithImage:(UIImage *)emotion;

@end

NS_ASSUME_NONNULL_END