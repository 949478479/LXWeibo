//
//  LXPhotoBrowserController.h
//
//  Created by 从今以后 on 15/10/13.
//  Copyright © 2015年 apple. All rights reserved.
//

@import UIKit;
#import "LXPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXPhotoBrowserController : UIViewController

@property (nonatomic) NSUInteger currentPhotoIndex;

@property (nonatomic, copy) NSArray<id<LXPhoto>> *photos;

+ (instancetype)photoBrower;

@end

NS_ASSUME_NONNULL_END
