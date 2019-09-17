//
//  LFBlurryBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/11.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBlurryBrush.h"
#import "LFBrush+create.h"
#import "LFBrushCache.h"

NSString *const LFBlurryBrushImageColor = @"LFBlurryBrushImageColor";

@interface LFBlurryBrush ()

@end

@implementation LFBlurryBrush

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

- (instancetype)initWithImage:(UIImage *)image radius:(CGFloat)radius canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache
{
    self = [super init];
    if (self) {
        if (!useCache) {
            [[LFBrushCache share] removeObjectForKey:LFBlurryBrushImageColor];
        }
        UIColor *color = [[LFBrushCache share] objectForKey:LFBlurryBrushImageColor];
        if (color) {
            self->_lineColor = color;
        } else {
            if (image) {
//                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                __weak typeof(self) weakSelf = self;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    UIColor *patternColor = [image LFBB_patternGaussianColorWithSize:canvasSize filterHandler:^CIFilter *(CIImage *ciimage) {
                        //高斯模糊滤镜
                        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
                        [filter setDefaults];
                        [filter setValue:ciimage forKey:kCIInputImageKey];
                        //value 改变模糊效果值
                        [filter setValue:@(radius) forKey:kCIInputRadiusKey];
                        return filter;
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSLog(@"used time : %fs", ([[NSDate date] timeIntervalSince1970] - time));
                        if (weakSelf && patternColor) {
                            __strong typeof(self) strongSelf = weakSelf;
                            strongSelf->_lineColor = patternColor;
                            [[LFBrushCache share] setObject:patternColor forKey:LFBlurryBrushImageColor];
                        }
                    });
                });
            } else {
                NSAssert(image!=nil, @"LFBlurryBrush image is nil.");
            }
        }
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor
{
    NSAssert(NO, @"LFBlurryBrush cann't set line color.");
}

- (UIColor *)lineColor
{
    return _lineColor;
}

@end
