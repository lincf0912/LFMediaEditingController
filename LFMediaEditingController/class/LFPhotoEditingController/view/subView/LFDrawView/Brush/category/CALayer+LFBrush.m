//
//  CALayer+LFBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/17.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "CALayer+LFBrush.h"
#import <objc/runtime.h>

static const char * LFBrushLayerLevelKey = "LFBrushLayerLevelKey";

@implementation CALayer (LFBrush)

- (void)setLf_level:(NSInteger)lf_level
{
    objc_setAssociatedObject(self, LFBrushLayerLevelKey, @(lf_level), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)lf_level
{
    NSNumber *num = objc_getAssociatedObject(self, LFBrushLayerLevelKey);
    if (num != nil) {
        return [num integerValue];
    }
    return 0;
}

@end
