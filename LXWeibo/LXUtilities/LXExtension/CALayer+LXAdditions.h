//
//  CALayer+LXAdditions.h
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 apple. All rights reserved.
//

@import QuartzCore;

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (LXAdditions)

@property (nonatomic, assign) CGSize  lx_size;
@property (nonatomic, assign) CGFloat lx_width;
@property (nonatomic, assign) CGFloat lx_height;

@property (nonatomic, assign) CGPoint lx_origin;
@property (nonatomic, assign) CGFloat lx_originX;
@property (nonatomic, assign) CGFloat lx_originY;

@property (nonatomic, assign) CGFloat lx_positionX;
@property (nonatomic, assign) CGFloat lx_positionY;

@end

NS_ASSUME_NONNULL_END