//
//  CALayer+LXAdditions.m
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "CALayer+LXAdditions.h"

@implementation CALayer (LXAdditions)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - size

- (void)setLx_size:(CGSize)lx_size
{
    CGRect frame = self.frame;
    frame.size   = lx_size;
    self.frame   = frame;
}

- (CGSize)lx_size
{
    return self.frame.size;
}

- (void)setLx_width:(CGFloat)lx_width
{
    CGRect frame     = self.frame;
    frame.size.width = lx_width;
    self.frame       = frame;
}

- (CGFloat)lx_width
{
    return CGRectGetWidth(self.frame);
}

- (void)setLx_height:(CGFloat)lx_height
{
    CGRect frame      = self.frame;
    frame.size.height = lx_height;
    self.frame        = frame;
}

- (CGFloat)lx_height
{
    return CGRectGetHeight(self.frame);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - origin

- (void)setLx_origin:(CGPoint)lx_origin
{
    CGRect frame = self.frame;
    frame.origin = lx_origin;
    self.frame   = frame;
}

- (CGPoint)lx_origin
{
    return self.frame.origin;
}

- (void)setLx_originX:(CGFloat)lx_originX
{
    CGRect frame   = self.frame;
    frame.origin.x = lx_originX;
    self.frame     = frame;
}

- (CGFloat)lx_originX
{
    return CGRectGetMinX(self.frame);
}

- (void)setLx_originY:(CGFloat)lx_originY
{
    CGRect frame   = self.frame;
    frame.origin.y = lx_originY;
    self.frame     = frame;
}

- (CGFloat)lx_originY
{
    return CGRectGetMinY(self.frame);
}

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - position

- (void)setLx_positionX:(CGFloat)lx_positionX
{
    CGPoint position = self.position;
    position.x       = lx_positionX;
    self.position    = position;
}

- (CGFloat)lx_positionX
{
    return self.position.x;
}

- (void)setLx_positionY:(CGFloat)lx_positionY
{
    CGPoint position = self.position;
    position.y       = lx_positionY;
    self.position    = position;
}

- (CGFloat)lx_positionY
{
    return self.position.y;
}

@end