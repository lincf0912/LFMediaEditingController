//
//  LFDrawView.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/23.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFDrawView.h"

NSString *const kLFDrawViewData = @"LFDrawViewData";

@interface LFDrawView ()
{
    BOOL _isWork;
    BOOL _isBegan;
}
/** 画笔数据 */
@property (nonatomic, strong) NSMutableArray <NSDictionary *>*brushData;
/** 图层 */
@property (nonatomic, strong) NSMutableArray <CALayer *>*layerArray;

@end

@implementation LFDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    [[self.layer sublayers] enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        obj.frame = self.bounds;
//    }];
//}

- (void)customInit
{
    _layerArray = [@[] mutableCopy];
    _brushData = [@[] mutableCopy];
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.exclusiveTouch = YES;
//    self.layer.anchorPoint = CGPointMake(0, 0);
//    self.layer.position = CGPointMake(0, 0);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if ([event allTouches].count == 1 && self.brush) {
        _isWork = NO;
        _isBegan = YES;

        // 画笔落点
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        // 1.创建画布
        CALayer *layer = [self.brush createDrawLayerWithPoint:point];
        
        [self.layer addSublayer:layer];
        [self.layerArray addObject:layer];
        
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_isBegan || _isWork) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        if (!CGPointEqualToPoint(self.brush.currentPoint, point)) {
            if (_isBegan && self.drawBegan) self.drawBegan();
            _isBegan = NO;
            _isWork = YES;
            // 2.添加画笔路径坐标
            [self.brush addPoint:point];
        }        
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    
    if (_isBegan || _isWork) {
        // 3.添加画笔数据
        [self.brushData addObject:self.brush.allTracks];
    }
    
    if (_isWork) {
        if (self.drawEnded) self.drawEnded();
    } else if (_isBegan) {
        [self undo];
    }
    _isBegan = NO;
    _isWork = NO;
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_isBegan || _isWork) {
        // 3.添加画笔数据
        [self.brushData addObject:self.brush.allTracks];
    }
    
    if (_isWork) {
        if (self.drawEnded) self.drawEnded();
    } else if (_isBegan) {
        [self undo];
    }
    _isBegan = NO;
    _isWork = NO;
    
    [super touchesCancelled:touches withEvent:event];
}

//- (void)drawRect:(CGRect)rect{
//    //遍历数组，绘制曲线
//    for (LFDrawBezierPath *path in self.lineArray) {
//        [path.color setStroke];
//        [path setLineCapStyle:kCGLineCapRound];
//        [path stroke];
//    }
//}

- (BOOL)isDrawing
{
    return _isWork;
}

/** 是否可撤销 */
- (BOOL)canUndo
{
    return self.brushData.count;
}

//撤销
- (void)undo
{
    [self.layerArray.lastObject removeFromSuperlayer];
    [self.layerArray removeLastObject];
    [self.brushData removeLastObject];
}

#pragma mark  - 数据
- (NSDictionary *)data
{
    if (self.brushData.count) {
        return @{kLFDrawViewData:[self.brushData copy]};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    NSArray *brushData = data[kLFDrawViewData];
    if (brushData.count) {
        for (NSDictionary *allTracks in brushData) {
            CALayer *layer = [LFBrush drawLayerWithTrackDict:allTracks];
            if (layer) {
                [self.layer addSublayer:layer];
                [self.layerArray addObject:layer];
            }
        }
        [self.brushData addObjectsFromArray:brushData];
    }
}

@end
