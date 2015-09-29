//
//  LXRetweetedStatusCell.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/29.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXStatus;

@interface LXRetweetedStatusCell : UITableViewCell

- (CGFloat)heightWithStatus:(LXStatus *)status inTableView:(UITableView *)tableView;

- (void)configureWithStatus:(LXStatus *)status;

@end