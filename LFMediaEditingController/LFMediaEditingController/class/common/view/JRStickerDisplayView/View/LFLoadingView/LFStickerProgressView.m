//
//  LFVideoProgressView.m
//  LFPhotoBrowserDEMO
//
//  Created by LamTsanFeng on 2016/11/21.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import "LFStickerProgressView.h"

@interface LFStickerProgressView ()

/** 大小 */
@property (nonatomic, assign) CGRect circlesSize;
/** 后圆环 */
@property (nonatomic, strong) CAShapeLayer *backCircle;
/** 前圆环 */
@property (nonatomic, strong) CAShapeLayer *foreCircle;

@end

@implementation LFStickerProgressView

- (id)init
{
    return [self initWithFrame:CGRectMake(0.f, 0.f, 37.f, 37.f)];
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.circlesSize = CGRectMake(20, 1, 18, 18);
        [self resetProgressView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.backCircle) {
        BOOL animated = ([self.backCircle animationForKey:@"rotationAnimation"] != nil);
        /** 删除前记录是否存在动画 */
        [self.backCircle removeFromSuperlayer];
        [self addBackCircleWithSize:self.circlesSize.origin.x lineWidth:self.circlesSize.origin.y];
        if (animated) {
            [self startAnimation];
        }
    }
    if (self.foreCircle) {
        [self.foreCircle removeFromSuperlayer];
        [self addForeCircleWidthSize:self.circlesSize.size.width lineWidth:self.circlesSize.size.height];
        if (_progress > 0) {
            self.foreCircle.strokeEnd = _progress;
        }
    }
}

#pragma mark - 后圆环
-(void)addBackCircleWithSize:(CGFloat)radius lineWidth:(CGFloat)lineWidth
{
    CGRect foreCircle_frame = CGRectMake(self.bounds.size.width/2-radius,
                                         self.bounds.size.height/2-radius,
                                         radius*2,
                                         radius*2);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = foreCircle_frame;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                        radius:radius-lineWidth/2
                                                    startAngle:0
                                                      endAngle:M_PI*2
                                                     clockwise:YES];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.lineWidth = lineWidth;
    layer.lineCap = @"round";
    layer.strokeStart = 0;
    layer.strokeEnd = 1;
    self.backCircle = layer;
    [self.layer addSublayer:self.backCircle];
    [self stopAnimation];
}

#pragma mark - 前圆环
-(void)addForeCircleWidthSize:(CGFloat)radius lineWidth:(CGFloat)lineWidth
{
    CGRect foreCircle_frame = CGRectMake(self.bounds.size.width/2-radius,
                                         self.bounds.size.height/2-radius,
                                         radius*2,
                                         radius*2);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = foreCircle_frame;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius)
                                                        radius:radius-lineWidth/2
                                                    startAngle:-M_PI/2
                                                      endAngle:M_PI/180*270
                                                     clockwise:YES];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.lineWidth = lineWidth;
    layer.lineCap = @"buff";
    layer.strokeStart = 0;
    layer.strokeEnd = 0;
    self.foreCircle = layer;
    [self.layer addSublayer:self.foreCircle];
}

-(void)setProgress:(float)progress
{
    _progress = progress;
    
    if (progress >= 0) {
        
        if (self.backCircle == nil) {
            [self addBackCircleWithSize:self.circlesSize.origin.x lineWidth:self.circlesSize.origin.y];
        }
        if (self.foreCircle == nil) {
            [self addForeCircleWidthSize:self.circlesSize.size.width lineWidth:self.circlesSize.size.height];
        }
        
        self.foreCircle.strokeEnd = progress;
        if (self.foreCircle.strokeEnd > 0.99)
        {
            [self startAnimation];
            [self.foreCircle removeFromSuperlayer];
            self.foreCircle = nil;
        } else if(self.foreCircle.strokeEnd > 0)
        {
            [self stopAnimation];
        } else {
            [self startAnimation];
        }
    }
}
-(void)drawBackCircle:(BOOL)partial
{
    CGFloat startAngle = -((float)M_PI/2);
    CGFloat endAngle = (2 *(float)M_PI) + startAngle;
    CGFloat radius = self.circlesSize.origin.x;
    CGFloat lineWidth = self.circlesSize.origin.y;
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = lineWidth;
    if(partial){
        endAngle = (1.8f * (float)M_PI) + startAngle;
    }
    [processBackgroundPath addArcWithCenter:CGPointMake(radius, radius) radius:radius-lineWidth/2 startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.backCircle.path = processBackgroundPath.CGPath;
}

#pragma mark - 开启旋转
-(void)startAnimation
{
    if ([self.backCircle animationForKey:@"rotationAnimation"]) {
        return ;
    }
    [self drawBackCircle:YES];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.removedOnCompletion = NO;
    [self.backCircle addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

#pragma mark - 停止旋转
-(void)stopAnimation
{
    [self drawBackCircle:NO];
    [self.backCircle removeAllAnimations];
}

#pragma mark - 重置progressView
-(void)resetProgressView
{
    [self.backCircle removeFromSuperlayer];
    [self.foreCircle removeFromSuperlayer];
    self.backCircle = nil;
    self.foreCircle = nil;
    _progress = 0;
}


@end
