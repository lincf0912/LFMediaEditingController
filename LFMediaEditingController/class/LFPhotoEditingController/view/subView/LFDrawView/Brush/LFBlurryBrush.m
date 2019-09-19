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
        self.lineWidth = 25;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image radius:(CGFloat)radius canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache
{
    self = [super init];
    if (self) {
        if (image) {
            [LFBlurryBrush loadBrushImage:image radius:radius canvasSize:canvasSize useCache:useCache complete:nil];
        } else {
            NSAssert(image!=nil, @"LFBlurryBrush image is nil.");
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
    return [[LFBrushCache share] objectForKey:LFBlurryBrushImageColor];
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    UIColor *lineColor = trackDict[LFPaintBrushLineColor];
    if (lineColor) {
        [[LFBrushCache share] setForceObject:lineColor forKey:LFBlurryBrushImageColor];
    }
    return [super drawLayerWithTrackDict:trackDict];
    
}

+ (void)loadBrushImage:(UIImage *)image radius:(CGFloat)radius canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete
{
    if (!useCache) {
        [[LFBrushCache share] removeObjectForKey:LFBlurryBrushImageColor];
    }
    UIColor *color = [[LFBrushCache share] objectForKey:LFBlurryBrushImageColor];
    if (color) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    if (image) {
        //                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
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
                if (patternColor) {
                    [[LFBrushCache share] setForceObject:patternColor forKey:LFBlurryBrushImageColor];
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

+ (BOOL)blurryBrushCache
{
    UIColor *color = [[LFBrushCache share] objectForKey:LFBlurryBrushImageColor];
    return (BOOL)color;
}

@end
