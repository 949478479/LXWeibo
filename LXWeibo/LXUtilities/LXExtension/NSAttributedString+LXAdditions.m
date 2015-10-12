//
//  NSAttributedString+LXAdditions.m
//
//  Created by 从今以后 on 15/10/10.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "NSAttributedString+LXAdditions.h"

@implementation NSAttributedString (LXAdditions)

- (CGSize)lx_sizeWithBoundingSize:(CGSize)size
{
    return CGRectIntegral([self boundingRectWithSize:size
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                             context:nil]).size;
}

@end