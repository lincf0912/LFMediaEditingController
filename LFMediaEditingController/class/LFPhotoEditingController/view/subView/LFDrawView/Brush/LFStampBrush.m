//
//  LFStampBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/2.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFStampBrush.h"
#import "NSBundle+LFMediaEditing.h"

const NSString *LFBrushPatterns = @"LFBrushPatterns";
const NSString *LFBrushSpacing = @"LFBrushSpacing";
const NSString *LFBrushScale = @"LFBrushScale";

inline static CGFloat LFStampBrushDistancePoint(CGPoint p0, CGPoint p1) {
    if (LFBrushPointIsNull(p0) || LFBrushPointIsNull(p1)) {
        return 0;
    }
    return sqrt(pow(p0.x - p1.x, 2) + pow(p0.y - p1.y, 2));
}

inline LFStampBrush *LFStampBrushAnimal(void)
{
    LFStampBrush *brush = [LFStampBrush new];
    brush.patterns = @[@"animal/1", @"animal/2", @"animal/3", @"animal/4", @"animal/5"];
    brush.scale = 10.0;
    return brush;
}

inline LFStampBrush *LFStampBrushFruit(void)
{
    LFStampBrush *brush = [LFStampBrush new];
    brush.patterns = @[@"fruit/1", @"fruit/2", @"fruit/3", @"fruit/4", @"fruit/5", @"fruit/6"];
    brush.scale = 8.0;
    return brush;
}

inline LFStampBrush *LFStampBrushHeart(void)
{
    LFStampBrush *brush = [LFStampBrush new];
    brush.patterns = @[@"heart/1", @"heart/2", @"heart/3", @"heart/4", @"heart/5"];
    brush.scale = 4.0;
    return brush;
}

@interface LFStampBrush ()

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) CALayer *layer;

@property (nonatomic, strong) NSMapTable *cacheImageMap;

@end

@implementation LFStampBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        _spacing = 1.f;
        _scale = 4.f;
        _cacheImageMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return self;
}

- (void)setPatterns:(NSArray<NSString *> *)patterns
{
    _patterns = patterns;
    [_cacheImageMap removeAllObjects];
}

- (void)addPoint:(CGPoint)point
{
    CGFloat distance = LFStampBrushDistancePoint(self.currentPoint, point);
    CGFloat width = self.lineWidth*self.scale;
    if(distance == 0 || distance >= (width + self.spacing)){

        CGRect rect = CGRectMake(point.x-width/2, point.y-width/2, width, width);
        
        if ([self drawSubLayerInLayerAtRect:rect]) {
            
            [super addPoint:point];
        }
    }
}

- (CALayer *)createDrawLayerWithPoint:(CGPoint)point
{
    /**
     忽略第一个落点。可能是误操作，知道真正滑动时才触发。
     */
    [super createDrawLayerWithPoint:LFBrushPointNull];
    self.index = 0;
    
    CALayer *layer = [[self class] createLayer];
    self.layer = layer;
    
    return layer;
}

- (NSDictionary *)allTracks
{
    NSDictionary *superAllTracks = [super allTracks];
    
    NSMutableDictionary *myAllTracks = nil;
    if (superAllTracks) {
        myAllTracks = [NSMutableDictionary dictionary];
        [myAllTracks addEntriesFromDictionary:superAllTracks];
        [myAllTracks addEntriesFromDictionary:@{LFBrushPatterns:self.patterns,
                                                LFBrushSpacing:@(self.spacing),
                                                LFBrushScale:@(self.scale)
                                                }];
    }
    return myAllTracks;
}

+ (CALayer *__nullable)drawLayerWithTrackDict:(NSDictionary *)trackDict
{
    CGFloat lineWidth = [trackDict[LFBrushLineWidth] floatValue];
    NSArray <NSString *> *patterns = trackDict[LFBrushPatterns];
//    CGFloat spacing = [trackDict[LFBrushSpacing] floatValue];
    CGFloat scale = [trackDict[LFBrushScale] floatValue];
    NSArray <NSString /*CGPoint*/*>*allPoints = trackDict[LFBrushAllPoints];
    
    if (allPoints) {
        CGFloat width = lineWidth*scale;
        CALayer *layer = [[self class] createLayer];
        NSMapTable *cacheImageMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
        NSInteger index = 0;
        for (NSString *pointStr in allPoints) {
            CGPoint point = CGPointFromString(pointStr);
            
            UIImage *image = [[self class] cacheImageIndex:index patterns:patterns cacheImageMap:&cacheImageMap];
            if (image == nil) continue;
            
            CGRect rect = CGRectMake(point.x-width/2, point.y-width/2, width, width);
            
            CALayer *subLayer = [[self class] createSubLayerWithImage:image rect:rect];
            
            [layer addSublayer:subLayer];
            
            index++;
        }
        return layer;
    }
    return nil;
}

#pragma mark - private
+ (UIImage *)cacheImageIndex:(NSInteger)index patterns:(NSArray <NSString *>*)patterns cacheImageMap:(NSMapTable **)cacheImageMap
{
    NSInteger count = patterns.count;
    NSString *imageName = patterns[index%count];
    if (0==imageName.length) return nil;
    
    UIImage *image = nil;
    
    if (cacheImageMap) {
        image = [*cacheImageMap objectForKey:imageName];
    }
    
    if (image == nil) {
        /**
         framework内部加载
         */
        image = [NSBundle LFME_brushImageNamed:imageName];
    }
    if (image == nil) {
        /**
         framework外部加载
         */
        image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]];
    }
    if (image && cacheImageMap) {
        [*cacheImageMap setObject:image forKey:imageName];
    }
    
    return image;
}

+ (CALayer *)createLayer
{
    CALayer *layer = [CALayer new];
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

+ (CALayer *)createSubLayerWithImage:(UIImage *)image rect:(CGRect)rect
{
    if (image == nil) return nil;
    
    CALayer *subLayer = [CALayer new];
    subLayer.frame = rect;
    subLayer.contentsScale = [UIScreen mainScreen].scale;
    subLayer.contentsGravity = kCAGravityResizeAspect;
    subLayer.contents = (__bridge id _Nullable)(image.CGImage);
    
    return subLayer;
}

- (BOOL)drawSubLayerInLayerAtRect:(CGRect)rect
{
    NSMapTable *cacheImageMap = self.cacheImageMap;
    UIImage *image = [[self class] cacheImageIndex:self.index patterns:self.patterns cacheImageMap:&cacheImageMap];
    
    if (image == nil) return NO;
    
    CALayer *subLayer = [[self class] createSubLayerWithImage:image rect:rect];
    
    [self.layer addSublayer:subLayer];
    
    self.index++;
    
    return YES;
}

@end
