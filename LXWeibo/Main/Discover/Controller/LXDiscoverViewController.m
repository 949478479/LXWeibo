//
//  LXDiscoverViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/9/23.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "LXDiscoverViewController.h"

@interface LXDiscoverViewController ()

@property (nonatomic, weak) IBOutlet UITextField *searchField;

@end

@implementation LXDiscoverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 文本框两侧与屏幕间距 8 点.如果设置间距为 20 点,一旦输入很多字符超过文本框显示范围,
    // 第一次注销响应者时文本框会神奇地变宽...变为距离屏幕边缘 8 点.试了下直接设置为 8 点间距后就没再出过这个问题.
    _searchField.lx_width = self.view.lx_width - 16;
}

@end