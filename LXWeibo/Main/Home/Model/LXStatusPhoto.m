//
//  LXStatusPhoto.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXStatusPhoto.h"

@implementation LXStatusPhoto

- (void)setThumbnail_pic:(NSString *)thumbnail_pic
{
    _thumbnail_pic = [thumbnail_pic copy];

    _bmiddle_pic = [thumbnail_pic stringByReplacingOccurrencesOfString:@"thumbnail"
                                                            withString:@"bmiddle"];

    _original_pic = [thumbnail_pic stringByReplacingOccurrencesOfString:@"thumbnail"
                                                             withString:@"large"];
}

@end