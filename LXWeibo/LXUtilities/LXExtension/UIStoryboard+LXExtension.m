//
//  UIStoryboard+LXExtension.m
//
//  Created by 从今以后 on 15/9/12.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "UIStoryboard+LXExtension.h"

@implementation UIStoryboard (LXExtension)

+ (void)lx_showInitialViewControllerWithStoryboardName:(NSString *)storyboardName
{
    NSAssert(storyboardName.length > 0, @"参数 storyboardName 为 nil 或空字符串.");

    UIStoryboard *storyboard = [self storyboardWithName:storyboardName bundle:nil];

    NSAssert(storyboard, @"文件不存在 => %@", [NSString stringWithFormat:@"%@.storyboard", storyboardName]);

    UIViewController *rootViewController = [storyboard instantiateInitialViewController];

    NSAssert(rootViewController, @"%@ 未指定 initial 控制器.",
             [NSString stringWithFormat:@"%@.storyboard", storyboardName]);

    LXKeyWindow().rootViewController = rootViewController;
}

+ (__kindof UIViewController *)lx_instantiateViewControllerWithStoryboardName:(NSString *)storyboardName
                                                                   identifier:(NSString *)identifier
{
    NSAssert(storyboardName.length > 0, @"参数 storyboardName 为 nil 或空字符串.");

    UIStoryboard *storyboard = [self storyboardWithName:storyboardName bundle:nil];

    NSAssert(storyboard, @"文件不存在 => %@", [NSString stringWithFormat:@"%@.storyboard", storyboardName]);
    
    if (identifier) {
        return [storyboard instantiateViewControllerWithIdentifier:identifier];
    }

    UIViewController *initialVC = [storyboard instantiateInitialViewController];

    NSAssert(initialVC, @"%@ 未指定 initial 控制器.",
             [NSString stringWithFormat:@"%@.storyboard", storyboardName]);

    return initialVC;
}

@end