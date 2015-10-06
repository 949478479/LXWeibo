//
//  UITextView+LXExtension.m
//
//  Created by 从今以后 on 15/10/6.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "UITextView+LXExtension.h"

@implementation UITextView (LXExtension)

- (void)lx_insertEmotionAttributedStringWithImage:(UIImage *)emotion
{
    UIFont *font = self.font;
    NSRange selectedRange = self.selectedRange; // 获取当前选中范围.

    NSTextAttachment *textAttachment = [NSTextAttachment new];
    {
        textAttachment.image  = emotion;

        // 设置图片高度为字体行高,宽度根据纵横比计算得出.默认 y 坐标会偏上,设置该值为 font.descender 即可水平对齐.
        CGFloat lineHeight = font.lineHeight;
        CGFloat radio = emotion.size.height / emotion.size.width;
        textAttachment.bounds = CGRectMake(0, font.descender, lineHeight / radio, lineHeight);
    }

    NSAttributedString *imageAttributedString =
        [NSAttributedString attributedStringWithAttachment:textAttachment];

    NSMutableAttributedString *attributedString = self.attributedText.mutableCopy;
    {
        // 插入到当前选中位置.
        [attributedString replaceCharactersInRange:selectedRange
                              withAttributedString:imageAttributedString];

        // 设置富文本会导致 textView 的 font 变为另一种富文本默认字体,因此需要专门指定字体为原先字体.
        [attributedString addAttribute:NSFontAttributeName
                                 value:font
                                 range:(NSRange){0,attributedString.length}];
    }

    self.attributedText = attributedString;
    self.selectedRange = NSMakeRange(selectedRange.location + 1, 0); // 恢复光标到插入点后.
}

@end