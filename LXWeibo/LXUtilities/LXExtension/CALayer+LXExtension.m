//
//  CALayer+LXExtension.m
//  这到底是个什么鬼
//
//  Created by 从今以后 on 15/10/5.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "CALayer+LXExtension.h"

@implementation CALayer (LXExtension)

///////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - size

- (void)setLx_size:(CGSize)lx_size
{
    CGRect bounds = self.bounds;
    bounds.size   = lx_size;
    self.bounds   = bounds;
}

- (CGSize)lx_size
{
    return self.bounds.size;
}

- (void)setLx_width:(CGFloat)lx_width
{
    CGRect bounds     = self.bounds;
    bounds.size.width = lx_width;
    self.bounds       = bounds;
}

- (CGFloat)lx_width
{
    return CGRectGetWidth(self.bounds);
}

- (void)setLx_height:(CGFloat)lx_height
{
    CGRect bounds      = self.bounds;
    bounds.size.height = lx_height;
    self.bounds        = bounds;
}

- (CGFloat)lx_height
{
    return CGRectGetHeight(self.bounds);
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