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
        self.lineWidth = 25;
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor
{
    NSAssert(NO, @"LFMosaicBrush cann't set line color.");
}

- (UIColor *)lineColor
{
    UIColor *color = [[LFBrushCache share] objectForKey:LFMosaicBrushImageColor];
    
    NSAssert(color!=nil, @"call LFMosaicBrush loadBrushImage:scale:canvasSize:useCache:complete: method.");
    
    return color;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    UIColor *lineColor = trackDict[LFPaintBrushLineColor];
    if (lineColor) {
        [[LFBrushCache share] setForceObject:lineColor forKey:LFMosaicBrushImageColor];
    }
    return [super drawLayerWithTrackDict:trackDict];
    
}

+ (void)loadBrushImage:(UIImage *)image scale:(CGFloat)scale canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete
{
    if (!useCache) {
        [[LFBrushCache share] removeObjectForKey:LFMosaicBrushImageColor];
    }
    UIColor *color = [[LFBrushCache share] objectForKey:LFMosaicBrushImageColor];
    if (color) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    if (image) {
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
                
                if (patternColor) {
                    [[LFBrushCache share] setForceObject:patternColor forKey:LFMosaicBrushImageColor];
                }
                
                if (complete) {
                    complete((BOOL)patternColor);
                }
            });
        });
    } else {
        if (complete) {
            complete(NO);
        }
    }
}

+ (BOOL)mosaicBrushCache
{
    UIColor *color = [[LFBrushCache share] objectForKey:LFMosaicBrushImageColor];
    return (BOOL)color;
}

@end
