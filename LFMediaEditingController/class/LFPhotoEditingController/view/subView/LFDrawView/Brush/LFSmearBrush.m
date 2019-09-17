//
//  LFSmearBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/16.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFSmearBrush.h"
#import "NSBundle+LFMediaEditing.h"
#import "LFBrushCache.h"

NSString *const LFSmearBrushName = @"EditImageSmearBrush";
NSString *const LFSmearBrushPoints = @"LFSmearBrushPoints";
NSString *const LFSmearBrushPoint = @"LFSmearBrushPoint";
NSString *const LFSmearBrushAngle = @"LFSmearBrushAngle";
NSString *const LFSmearBrushColor = @"LFSmearBrushColor";

@interface LFSmearBrush (color)

@end

@implementation LFSmearBrush (color)

#pragma mark - 获取屏幕的颜色块
- (UIColor *)colorOfPoint:(CGPoint)point
{
    UIColor *color = nil;
    @autoreleasepool {
        unsigned char pixel[4] = {0};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(pixel,
                                                     1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
        
        CGContextTranslateCTM(context, -point.x, -point.y);
        
        [[[UIApplication sharedApplication] keyWindow].layer renderInContext:context];
        
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        color = [UIColor colorWithRed:pixel[0]/255.0
                                green:pixel[1]/255.0 blue:pixel[2]/255.0
                                alpha:pixel[3]/255.0];
    }
    
    return color;
}

@end

@interface LFSmearBrush ()

@property (nonatomic, weak) CALayer *layer;

@property (nonatomic, strong) NSMutableArray <NSDictionary *>*points;

@end

@implementation LFSmearBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)addPoint:(CGPoint)point
{
    [super addPoint:point];
    
    UIImage *image = [[self class] cacheImageWithName:LFSmearBrushName];
    
    CGFloat angle = LFBrushAngleBetweenPoint(self.previousPoint, point);
    // 调整角度，顺着绘画方向。
    angle = 360-angle;
    // 随机坐标
    point.x += floorf(arc4random()%((int)(image.size.width)+1)) - image.size.width/2;
    point.y += floorf(arc4random()%((int)(image.size.height)+1)) - image.size.width/2;
    
    //转换屏幕坐标，获取颜色块
    UIColor *color = nil;
    UIView *drawView = (UIView *)self.layer.superlayer.delegate;
    if ([drawView isKindOfClass:[UIView class]]) {
        CGPoint screenPoint = [drawView convertPoint:point toView:[UIApplication sharedApplication].keyWindow];
        color = [self colorOfPoint:screenPoint];
    }

    CALayer *subLayer = [[self class] createSubLayerWithImage:image lineWidth:self.lineWidth point:point angle:angle color:color];
    
    [self.layer addSublayer:subLayer];
    
    // 记录坐标数据
    NSMutableDictionary *pointDict = [NSMutableDictionary dictionaryWithCapacity:2];
    [pointDict setObject:NSStringFromCGPoint(point) forKey:LFSmearBrushPoint];
    [pointDict setObject:@(angle) forKey:LFSmearBrushAngle];
    
    if (color) {
        [pointDict setObject:color forKey:LFSmearBrushColor];
    }
    [self.points addObject:pointDict];
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    [super createDrawLayerWithPoint:point];
    _points = [NSMutableArray array];
    
    CALayer *layer = [[self class] createLayer];
    self.layer = layer;
    
    return layer;
}

- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks && self.points.count) {
        myAllTracks = [NSMutableDictionary dictionary];
        [myAllTracks addEntriesFromDictionary:superAllTracks];
        [myAllTracks addEntriesFromDictionary:@{
                                                LFSmearBrushPoints:self.points
                                                }];
    }
    return myAllTracks;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    CGFloat lineWidth = [trackDict[LFBrushLineWidth] floatValue];
//    NSArray <NSString /*CGPoint*/*>*allPoints = trackDict[LFBrushAllPoints];
    NSArray <NSDictionary *>*points = trackDict[LFSmearBrushPoints];
    
    if (points.count > 0) {
        CALayer *layer = [[self class] createLayer];
        UIImage *image = [[self class] cacheImageWithName:LFSmearBrushName];
        NSDictionary *pointDict = nil;
        for (NSInteger i=0; i<points.count; i++) {
            
            pointDict = points[i];
            
            CGPoint point = CGPointFromString(pointDict[LFSmearBrushPoint]);
            
            CGFloat angle = [pointDict[LFSmearBrushAngle] floatValue];
            
            UIColor *color = pointDict[LFSmearBrushColor];
            
            CALayer *subLayer = [[self class] createSubLayerWithImage:image lineWidth:lineWidth point:point angle:angle color:color];
            
            [layer addSublayer:subLayer];
        }
        return layer;
    }
    return nil;
}

#pragma mark - private
+ (UIImage *)cacheImageWithName:(NSString *)name
{
    if (0==name.length) return nil;
    
    LFBrushCache *imageCache = [LFBrushCache share];
    UIImage *image = [imageCache objectForKey:name];
    if (image) {
        return image;
    }
    
    if (image == nil) {
        /**
         framework内部加载
         */
        image = [NSBundle LFME_brushImageNamed:name];
    }
    
    if (image) {
        @autoreleasepool {
            //redraw image using device context
            UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
            [image drawAtPoint:CGPointZero];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        [imageCache setObject:image forKey:name];
    }
    
    return image;
}

+ (CALayer *)createLayer
{
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

+ (CALayer *)createSubLayerWithImage:(UIImage *)image lineWidth:(CGFloat)lineWidth point:(CGPoint)point angle:(CGFloat)angle color:(UIColor *)color
{
    if (image == nil) return nil;
    
    CGFloat height = lineWidth;
    CGSize size = CGSizeMake(image.size.width*height/image.size.height, height);
    CGRect rect = CGRectMake(point.x-size.width/2, point.y-size.height/2, size.width, size.height);
    
    CALayer *subLayer = [CALayer layer];
    subLayer.frame = rect;
    subLayer.contentsScale = [UIScreen mainScreen].scale;
    subLayer.contentsGravity = kCAGravityResizeAspect;
    subLayer.contents = (__bridge id _Nullable)(image.CGImage);
    
    if (color) {
        CALayer *markLayer = [CALayer layer];
        markLayer.frame = rect;
        markLayer.contentsScale = [UIScreen mainScreen].scale;
        markLayer.backgroundColor = color.CGColor;
        subLayer.frame = markLayer.bounds;
        
        markLayer.transform = CATransform3DMakeRotation((angle * M_PI / 180.0), 0, 0, 1);
        markLayer.mask = subLayer;
        markLayer.masksToBounds = YES;
        
        return markLayer;
    }
    subLayer.transform = CATransform3DMakeRotation((angle * M_PI / 180.0), 0, 0, 1);
    
    return subLayer;
}

@end
