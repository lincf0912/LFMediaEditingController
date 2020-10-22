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
    return [self extraAspectRatioWithWidth:width andHeight:height andAspectDelimiter:nil autoAspectRatio:TRUE];
}

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height
                          autoAspectRatio:(BOOL)autoAspectRatio
{
    return [self extraAspectRatioWithWidth:width andHeight:height andAspectDelimiter:nil autoAspectRatio:autoAspectRatio];
}

+ (instancetype)extraAspectRatioWithWidth:(int)width
                                andHeight:(int)height
                       andAspectDelimiter:(NSString  * _Nullable)aspectDelimiter
                          autoAspectRatio:(BOOL)autoAspectRatio
{
    return [[self alloc] initWithWidth:width andHeight:height andAspectDelimiter:aspectDelimiter autoAspectRatio:autoAspectRatio];
}

- (instancetype)initWithWidth:(int)width
                    andHeight:(int)height
           andAspectDelimiter:(NSString  * _Nullable)aspectDelimiter
              autoAspectRatio:(BOOL)autoAspectRatio
{
    self = [super init];
    if (self) {
        _lf_aspectWidth = width;
        _lf_aspectHeight = height;
        _lf_aspectDelimiter = aspectDelimiter ?: @"x";
        _autoAspectRatio = autoAspectRatio;
    }
    return self;
}

@end
