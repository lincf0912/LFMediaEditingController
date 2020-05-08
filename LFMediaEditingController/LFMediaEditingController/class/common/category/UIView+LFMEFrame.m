//
//  UIView+LFFrame.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/13.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "UIView+LFMEFrame.h"

@implementation UIView (LFMEFrame)

- (void)setLfme_x:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setLfme_y:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)lfme_x
{
    return self.frame.origin.x;
}

- (CGFloat)lfme_y
{
    return self.frame.origin.y;
}

- (void)setLfme_centerX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)lfme_centerX
{
    return self.center.x;
}

- (void)setLfme_centerY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)lfme_centerY
{
    return self.center.y;
}

- (void)setLfme_width:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setLfme_height:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)lfme_height
{
    return self.frame.size.height;
}

- (CGFloat)lfme_width
{
    return self.frame.size.width;
}

- (void)setLfme_size:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)lfme_size
{
    return self.frame.size;
}

- (void)setLfme_origin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)lfme_origin
{
    return self.frame.origin;
}


@end
