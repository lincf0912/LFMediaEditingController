//
//  LFScrollView.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/13.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFScrollView.h"

@implementation LFScrollView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delaysContentTouches = NO;
        self.canCancelContentTouches = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delaysContentTouches = NO;
        self.canCancelContentTouches = NO;
    }
    return self;
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return [super touchesShouldBegin:touches withEvent:event inContentView:view];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return [super touchesShouldCancelInContentView:view];
}

@end
