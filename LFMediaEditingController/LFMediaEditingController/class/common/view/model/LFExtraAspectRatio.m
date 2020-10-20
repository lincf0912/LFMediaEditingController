//
//  LFExtraAspectRatio.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2020/10/20.
//  Copyright © 2020 LamTsanFeng. All rights reserved.
//

#import "LFExtraAspectRatio.h"

@implementation LFExtraAspectRatio

+ (instancetype)extraAspectRatioWithWidth:(int)width andHeight:(int)height
{
    return [[self alloc] initWithWidth:width andHeight:height];
}

- (instancetype)initWithWidth:(int)width andHeight:(int)height
{
    self = [super init];
    if (self) {
        _lf_aspectWidth = width;
        _lf_aspectHeight = height;
    }
    return self;
}

@end
