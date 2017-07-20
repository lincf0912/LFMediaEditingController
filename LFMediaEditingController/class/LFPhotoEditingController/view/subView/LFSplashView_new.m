//
//  LFSplashView_new.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/6/7.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFSplashView_new.h"
#import "LFSplashLayer.h"
#import "LFMediaEditingHeader.h"

NSString *const kLFSplashViewData = @"LFSplashViewData";

@interface LFSplashView_new ()
{
    BOOL _isWork;
    BOOL _isBegan;
}
/** 图层 */
@property (nonatomic, strong) NSMutableArray <LFSplashLayer *>*layerArray;

@property (nonatomic, assign) BOOL isErase;
/** 方形大小 */
@property (nonatomic, assign) CGFloat squareWidth;
/** 图片大小 */
@property (nonatomic, assign) CGSize paintSize;
@end

@implementation LFSplashView_new

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
    _squareWidth = 15.f;
    _paintSize = CGSizeMake(50, 50);
    _state = LFSplashStateType_Mosaic;
    _layerArray = [@[] mutableCopy];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.allObjects.count == 1) {
        _isWork = NO;
        _isBegan = YES;
        
        //1、触摸坐标
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        //2、创建LFSplashBlur
        LFSplashBlur *blur = (self.state == LFSplashStateType_Paintbrush ? [LFSplashImageBlur new] : [LFSplashBlur new]);
        blur.color = self.splashColor ? self.splashColor(point) : nil;
        blur.point = point;
        if (self.state == LFSplashStateType_Mosaic) {
            blur.rect = CGRectMake(point.x-self.squareWidth/2, point.y-self.squareWidth/2, self.squareWidth, self.squareWidth);
        } else if (self.state == LFSplashStateType_Paintbrush) {
            blur.rect = CGRectMake(point.x-self.paintSize.width/2, point.y-self.paintSize.height/2, self.paintSize.width, self.paintSize.height);
        }
        
        LFSplashLayer *layer = [LFSplashLayer layer];
        layer.frame = self.bounds;
        [layer.lineArray addObject:blur];
        
        [self.layer addSublayer:layer];
        [self.layerArray addObject:layer];

    
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.allObjects.count == 1) {
        
        
        //1、触摸坐标
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        
        /** 获取上一个对象坐标判断是否重叠 */
        LFSplashLayer *layer = self.layerArray.lastObject;
        LFSplashBlur *prevBlur = layer.lineArray.lastObject;
        
        if (!CGPointEqualToPoint(prevBlur.point, point)) {
            if (_isBegan && self.splashBegan) self.splashBegan();
            _isWork = YES;
            _isBegan = NO;
            if (self.state == LFSplashStateType_Mosaic) {
                
                if (CGRectContainsPoint(prevBlur.rect, point) == NO) {
                    CGFloat pointX = point.x, pointY = point.y;
                    /** 计算x */
                    if (pointX > CGRectGetMaxX(prevBlur.rect)) {
                        pointX = CGRectGetMaxX(prevBlur.rect);
                    } else if (pointX < CGRectGetMinX(prevBlur.rect)) {
                        pointX = CGRectGetMinX(prevBlur.rect) - CGRectGetWidth(prevBlur.rect);
                    } else {
                        pointX = CGRectGetMinX(prevBlur.rect);
                    }
                    /** 计算y */
                    if (pointY > CGRectGetMaxY(prevBlur.rect)) {
                        pointY = CGRectGetMaxY(prevBlur.rect);
                    } else if (pointY < CGRectGetMinY(prevBlur.rect)) {
                        pointY = CGRectGetMinY(prevBlur.rect) - CGRectGetHeight(prevBlur.rect);
                    } else {
                        pointY = CGRectGetMinY(prevBlur.rect);
                    }
                    //2、创建LFSplashBlur
                    LFSplashBlur *blur = [LFSplashBlur new];
                    blur.point = point;
                    blur.rect = CGRectMake(pointX, pointY, CGRectGetWidth(prevBlur.rect), CGRectGetHeight(prevBlur.rect));
                    blur.color = self.splashColor ? self.splashColor(point) : nil;
                    
                    [layer.lineArray addObject:blur];
                    [layer setNeedsDisplay];
                }
            } else if (self.state == LFSplashStateType_Paintbrush) {
                /** 限制绘画的间隙 */
                if (CGRectContainsPoint(prevBlur.rect, point) == NO) {
                    //2、创建LFSplashBlur
                    LFSplashImageBlur *blur = [LFSplashImageBlur new];
                    blur.point = point;
                    blur.imageName = @"EditImageMosaicBrush.png";
                    blur.color = self.splashColor ? self.splashColor(point) : nil;
                    /** 新增随机位置 */
                    int x = self.paintSize.width + 20;
                    float randomX = floorf(arc4random()%x) - x/2;
                    blur.rect = CGRectMake(point.x-self.paintSize.width/2 + randomX, point.y-self.paintSize.height/2, self.paintSize.width, self.paintSize.height);
                    
                    [layer.lineArray addObject:blur];
                    
                    /** 新增额外对象 密集图片 */
                    [layer setNeedsDisplay];
                }
            }
        }
        
        
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([event allTouches].count == 1){
        if (_isWork) {
            if (self.splashEnded) self.splashEnded();
        } else {
            [self undo];
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([event allTouches].count == 1){
        if (_isWork) {
            if (self.splashEnded) self.splashEnded();
        } else {
            [self undo];
        }
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

/** 是否可撤销 */
- (BOOL)canUndo
{
    return self.layerArray.count;
}

//撤销
- (void)undo
{
    LFSplashLayer *layer = self.layerArray.lastObject;
    [layer removeFromSuperlayer];
    [self.layerArray removeLastObject];
}

#pragma mark  - 数据
- (NSDictionary *)data
{
    if (self.layerArray.count) {
        NSMutableArray *lineArray = [@[] mutableCopy];
        for (LFSplashLayer *layer in self.layerArray) {
            [lineArray addObject:layer.lineArray];
        }
        return @{kLFSplashViewData:[lineArray copy]};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    NSArray *lineArray = data[kLFSplashViewData];
    for (NSArray *subLineArray in lineArray) {
        LFSplashLayer *layer = [LFSplashLayer layer];
        layer.frame = self.bounds;
        [layer.lineArray addObjectsFromArray:subLineArray];
        
        [self.layer addSublayer:layer];
        [self.layerArray addObject:layer];
        [layer setNeedsDisplay];
    }
}

@end
