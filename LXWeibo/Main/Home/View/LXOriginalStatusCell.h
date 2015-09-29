//
//  LXOriginalStatusCell.h
//  LXWeibo
//
//  Created by 从今以后 on 15/9/28.
//  Copyright © 2015年 从今以后. All rights reserved.
//

@import UIKit;
@class LXStatus;

@interface LXOriginalStatusCell : UITableViewCell

- (CGFloat)heightWithStatus:(LXStatus *)status;

- (void)configureWithStatus:(LXStatus *)status;

@end