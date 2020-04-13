//
//  LFEraserBrush.m
//  DrawDemo
//
//  Created by TsanFeng Lam on 2020/3/24.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "LFEraserBrush.h"
#import "LFBrush+create.h"
#import "LFBrushCache.h"

NSString *const LFEraserBrushImageColor = @"LFEraserBrushImageColor";

NSString *const LFEraserBrushImageLayers = @"LFEraserBrushImageLayers";

@interface LFEraserBrush ()

@end

@implementation LFEraserBrush

@synthesize lineColor = _lineColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_lineColor = nil;
        self.lineWidth += 4;
    }
    return self;
}


- (void)setLineColor:(UIColor *)lineColor
{
    NSAssert(NO, @"LFEraserBrush cann't set line color.");
}

- (UIColor *)lineColor
{
    UIColor *color = [[LFBrushCache share] objectForKey:LFEraserBrushImageColor];
    
    NSAssert(color!=nil, @"call LFEraserBrush loadBrushImage:radius:canvasSize:useCache:complete: method.");
    
    return color;
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    CALayer *layer = [super createDrawLayerWithPoint:point];
    if (layer) {
        
        NSHashTable *layers = [[LFBrushCache share] objectForKey:LFEraserBrushImageLayers];
        [layers addObject:layer];
    }
    return layer;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    UIColor *lineColor = trackDict[LFPaintBrushLineColor];
    if (lineColor) {
        [[LFBrushCache share] setForceObject:lineColor forKey:LFEraserBrushImageColor];
    }
    CALayer *layer = [super drawLayerWithTrackDict:trackDict];
    if (layer) {
        NSHashTable *layers = [[LFBrushCache share] objectForKey:LFEraserBrushImageLayers];
        [layers addObject:layer];
    }
    return layer;
}

+ (void)loadEraserImage:(UIImage *)image canvasSize:(CGSize)canvasSize useCache:(BOOL)useCache complete:(void (^ _Nullable )(BOOL success))complete
{
    
    NSHashTable *layers = [[LFBrushCache share] objectForKey:LFEraserBrushImageLayers];
    if (layers == nil) {
        layers = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [[LFBrushCache share] setForceObject:layers forKey:LFEraserBrushImageLayers];
    }
    
    if (!useCache) {
        [[LFBrushCache share] removeObjectForKey:LFEraserBrushImageColor];
    }
    UIColor *color = [[LFBrushCache share] objectForKey:LFEraserBrushImageColor];
    if (color) {
        if (complete) {
            complete(YES);
        }
        return;
    }
    if (image) {
        //                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            UIColor *patternColor = [image LFBB_patternGaussianColorWithSize:canvasSize filterHandler:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                //                        NSLog(@"used time : %fs", ([[NSDate date] timeIntervalSince1970] - time));
                if (patternColor) {
                    [[LFBrushCache share] setForceObject:patternColor forKey:LFEraserBrushImageColor];
                }
                for (CAShapeLayer *layer in layers) {
                    layer.strokeColor = patternColor.CGColor;
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

+ (BOOL)eraserBrushCache
{
    UIColor *color = [[LFBrushCache share] objectForKey:LFEraserBrushImageColor];
    return (BOOL)color;
}

@end
