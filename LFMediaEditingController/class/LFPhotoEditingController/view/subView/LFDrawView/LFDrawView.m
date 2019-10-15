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

- (void)customInit
{
    _layerArray = [@[] mutableCopy];
    _brushData = [@[] mutableCopy];
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.exclusiveTouch = YES;
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
        
        if (layer) {
            /** 使用画笔的图层层级，层级越大，图层越低 */
            [self.layer.sublayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                /** 图层层级<=，放在该图层上方 */
                if (layer.lf_level <= obj.lf_level) {
                    [self.layer insertSublayer:layer above:obj];
                    *stop = YES;
                }
            }];
            /** 没有被加入到显示图层，直接放到最低 */
            if (layer.superlayer == nil) {
                [self.layer insertSublayer:layer atIndex:0];
            }
            [self.layerArray addObject:layer];
        } else {
            _isBegan = NO;
        }
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
    
    if (_isWork) {
        // 3.1.添加画笔数据
        id data = self.brush.allTracks;
        if (data) {
            [self.brushData addObject:data];
        }
        if (self.drawEnded) self.drawEnded();
    } else if (_isBegan) {
        // 3.2.移除开始时添加的图层
        [self.layerArray.lastObject removeFromSuperlayer];
        [self.layerArray removeLastObject];
    }
    _isBegan = NO;
    _isWork = NO;
    
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_isWork) {
        // 3.1.添加画笔数据
        id data = self.brush.allTracks;
        if (data) {
            [self.brushData addObject:data];
        }
        if (self.drawEnded) self.drawEnded();
    } else if (_isBegan) {
        // 3.2.移除开始时添加的图层
        [self.layerArray.lastObject removeFromSuperlayer];
        [self.layerArray removeLastObject];
    }
    _isBegan = NO;
    _isWork = NO;
    
    [super touchesCancelled:touches withEvent:event];
}

- (BOOL)isDrawing
{
    return _isWork;
}

/** 图层数量 */
- (NSUInteger)count
{
    return self.brushData.count;
}

/** 是否可撤销 */
- (BOOL)canUndo
{
    return self.count > 0;
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
                /** 使用画笔的图层层级，层级越大，图层越低 */
                [self.layer.sublayers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    /** 图层层级<=，放在该图层上方 */
                    if (layer.lf_level <= obj.lf_level) {
                        [self.layer insertSublayer:layer above:obj];
                        *stop = YES;
                    }
                }];
                /** 没有被加入到显示图层，直接放到最低 */
                if (layer.superlayer == nil) {
                    [self.layer insertSublayer:layer atIndex:0];
                }
                [self.layerArray addObject:layer];
            }
        }
        [self.brushData addObjectsFromArray:brushData];
    }
}

@end
