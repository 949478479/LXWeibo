//
//  LXSettingViewController.m
//  LXWeibo
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 从今以后. All rights reserved.
//

#import "LXUtilities.h"
#import "SDImageCache.h"
#import "LXStatusManager.h"
#import "LXSettingViewController.h"

@interface LXSettingViewController ()

@property (nonatomic, weak) IBOutlet UITableViewCell *clearStatusCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *clearImageCell;

@end

@implementation LXSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureCell];
}

- (void)configureCell
{
    NSString * (^formatedCacheSize)(float) = ^(float cacheSize) {
        if (cacheSize < 0.1) {
            return @"0 M";
        } else {
            return [NSString stringWithFormat:@"%.1f M", cacheSize];
        }
    };

    const float kBytePerMegabyte = 1000000.0;

    _clearStatusCell.detailTextLabel.text =
        formatedCacheSize([LXStatusManager statusCacheSize] / kBytePerMegabyte);

    _clearImageCell.detailTextLabel.text =
        formatedCacheSize([SDImageCache sharedImageCache].getSize / kBytePerMegabyte);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (cell == _clearStatusCell) { // 清除微博缓存.
        [LXStatusManager clearStatusCache];
        _clearStatusCell.detailTextLabel.text = @"0 M";
    } else if (cell == _clearImageCell) {
        [[SDImageCache sharedImageCache] clearDisk];
        _clearImageCell.detailTextLabel.text = @"0 M";
    }
}

@end