//
//  LFMosaicBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/12.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFMosaicBrush.h"
#import "LFBrush+create.h"
#import "LFBrushCache.h"

NSString *const LFMosaicBrushImageColor = @"LFMosaicBrushImageColor";

@interface LFMosaicBrush ()

@end

@implementation LFMosaicBrush

@synthesize lineColor = _lineColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_lineColor = nil;
        self.level = 5;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image scale:(CGFloat)scale canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache
{
    self = [super init];
    if (self) {
        if (!useCache) {
            [[LFBrushCache share] removeObjectForKey:LFMosaicBrushImageColor];
        }
        UIColor *color = [[LFBrushCache share] objectForKey:LFMosaicBrushImageColor];
        if (color) {
            self->_lineColor = color;
        } else {
            if (image) {
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    UIColor *patternColor = [image LFBB_patternGaussianColorWithSize:canvasSize filterHandler:^CIFilter *(CIImage *ciimage) {
                        //高斯模糊滤镜
                        CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
                        [filter setDefaults];
                        [filter setValue:ciimage forKey:kCIInputImageKey];
                        //value 改变马赛克的大小
                        [filter setValue:@(scale) forKey:kCIInputScaleKey];
                        return filter;
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (weakSelf && patternColor) {
                            __strong typeof(self) strongSelf = weakSelf;
                            strongSelf->_lineColor = patternColor;
                            [[LFBrushCache share] setObject:patternColor forKey:LFMosaicBrushImageColor];
                        }
                    });
                });
            } else {
                NSAssert(image!=nil, @"LFMosaicBrush image is nil.");
            }
        }
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor
{
    NSAssert(NO, @"LFMosaicBrush cann't set line color.");
}

- (UIColor *)lineColor
{
    return _lineColor;
}

@end
