//
//  LFMovingView.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/24.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFMovingView.h"
#import "LFMediaEditingHeader.h"
#import "LFStickerItem+View.h"

#define LFMovingView_margin 22

@interface LFMovingView ()
{
    UIView *_contentView;
    UIButton *_deleteButton;
    UIImageView *_circleView;
    
    CGFloat _scale;
    CGFloat _arg;
    
    CGPoint _initialPoint;
    CGFloat _initialArg;
    CGFloat _initialScale;
}

@property (nonatomic, assign) BOOL isActive;

@end

@implementation LFMovingView

+ (void)setActiveEmoticonView:(LFMovingView *)view
{
    static LFMovingView *activeView = nil;
    /** 停止取消激活 */
    [activeView cancelDeactivated];
    if(view != activeView){
        [activeView setActive:NO];
        activeView = view;
        [activeView setActive:YES];
        
        [activeView.superview bringSubviewToFront:activeView];
        
    }
    [activeView autoDeactivated];
}

- (void)dealloc
{
    [self cancelDeactivated];
}

#pragma mark - 自动取消激活
- (void)cancelDeactivated
{
    [LFMovingView cancelPreviousPerformRequestsWithTarget:self];
}

- (void)autoDeactivated
{
    [self performSelector:@selector(setActiveEmoticonView:) withObject:nil afterDelay:self.deactivatedDelay];
}

- (void)setActiveEmoticonView:(LFMovingView *)view
{
    [LFMovingView setActiveEmoticonView:view];
}

- (instancetype)initWithItem:(LFStickerItem *)item
{
    UIView *view = item.displayView;
    if (view == nil) {
        return nil;
    }
    self = [super initWithFrame:CGRectMake(0, 0, view.frame.size.width+LFMovingView_margin, view.frame.size.height+LFMovingView_margin)];
    if(self){
        _deactivatedDelay = 4.f;
        _view = view;
        _item = item;
        _contentView = [[UIView alloc] initWithFrame:view.bounds];
        _contentView.layer.borderColor = [[UIColor colorWithWhite:1.f alpha:0.8] CGColor];
        {
            // shadow
            _contentView.layer.shadowColor = [UIColor clearColor].CGColor;
            _contentView.layer.shadowOpacity = .5f;
            _contentView.layer.shadowOffset = CGSizeMake(0, 0);
            _contentView.layer.shadowRadius = 2.f;
            
            [self updateShadow];
        }
        
        _contentView.center = self.center;
        [_contentView addSubview:view];
        view.userInteractionEnabled = self.isActive;
        view.frame = _contentView.bounds;
        [self addSubview:_contentView];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, LFMovingView_margin, LFMovingView_margin);
        _deleteButton.center = _contentView.frame.origin;
        [_deleteButton addTarget:self action:@selector(pushedDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [_deleteButton setImage:[NSBundle LFME_imageNamed:@"ZoomingViewDelete.png"] forState:UIControlStateNormal];
        _deleteButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _deleteButton.layer.shadowOpacity = .5f;
        _deleteButton.layer.shadowOffset = CGSizeMake(0, 0);
        _deleteButton.layer.shadowRadius = 3;
        [self addSubview:_deleteButton];
        
        _circleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, LFMovingView_margin, LFMovingView_margin)];
        _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
        [_circleView setImage:[NSBundle LFME_imageNamed:@"ZoomingViewCircle.png"]];
        _circleView.layer.shadowColor = [UIColor blackColor].CGColor;
        _circleView.layer.shadowOpacity = .5f;
        _circleView.layer.shadowOffset = CGSizeMake(0, 0);
        _circleView.layer.shadowRadius = 3;
        [self addSubview:_circleView];
        
        _scale = 1.f;
        _screenScale = 1.f;
        _arg = 0;
        _minScale = .2f;
        _maxScale = 3.f;
        
        [self initGestures];
        [self setActive:NO];
    }
    return self;
}

- (void)setItem:(LFStickerItem *)item
{
    _item = item;
    [_view removeFromSuperview];
    _view = item.displayView;
    if (_view) {
        [_contentView addSubview:_view];
        _view.userInteractionEnabled = self.isActive;
        [self updateFrameWithViewSize:_view.frame.size];
    } else {
        [self removeFromSuperview];
    }
}

/** 更新坐标 */
- (void)updateFrameWithViewSize:(CGSize)viewSize
{
    /** 记录自身中心点 */
    CGPoint center = self.center;
    /** 更新自身大小 */
    CGRect frame = self.frame;
    frame.size = CGSizeMake(viewSize.width+LFMovingView_margin, viewSize.height+LFMovingView_margin);
    self.frame = frame;
    self.center = center;
    
    /** 还原缩放率 */
    _contentView.transform = CGAffineTransformIdentity;
    
    /** 更新主体大小 */
    CGRect contentFrame = _contentView.frame;
    contentFrame.size = viewSize;
    _contentView.frame = contentFrame;
    _contentView.center = center;
    _deleteButton.center = _contentView.frame.origin;
    _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
    [self updateShadow];
    /** 更新显示视图大小 */
    _view.frame = _contentView.bounds;
    
    [self setScale:_scale rotation:_arg];
}

- (void)updateShadow
{
    CGFloat shadowRadius = _contentView.layer.shadowRadius;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineJoinStyle = kCGLineJoinRound;
    
    UIBezierPath *leftPath = [UIBezierPath bezierPathWithRect:CGRectMake(-shadowRadius/2, 0, shadowRadius, _contentView.bounds.size.height-shadowRadius)];
    UIBezierPath *topPath = [UIBezierPath bezierPathWithRect:CGRectMake(shadowRadius/2, -shadowRadius/2, _contentView.bounds.size.width-shadowRadius, shadowRadius)];
    UIBezierPath *rightPath = [UIBezierPath bezierPathWithRect:CGRectMake(_contentView.bounds.size.width-shadowRadius/2, shadowRadius, shadowRadius, _contentView.bounds.size.height-shadowRadius)];
    UIBezierPath *bottomPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, _contentView.bounds.size.height-shadowRadius/2, _contentView.bounds.size.width-shadowRadius, shadowRadius)];
    [path appendPath:topPath];
    [path appendPath:leftPath];
    [path appendPath:rightPath];
    [path appendPath:bottomPath];
    
    _contentView.layer.shadowPath = path.CGPath;
}

- (void)initGestures
{
    self.userInteractionEnabled = YES;
    _contentView.userInteractionEnabled = YES;
    _circleView.userInteractionEnabled = YES;
    [_contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)]];
    [_contentView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)]];
    [_circleView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(circleViewDidPan:)]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* view= [super hitTest:point withEvent:event];
    if(view==self){
        view = nil;
    }
    if (view == nil) {
        [LFMovingView setActiveEmoticonView:nil];
    }
    return view;
}

- (void)setActive:(BOOL)active
{
    _isActive = active;
    _deleteButton.hidden = self.item.isMain ? YES : !active;
    _circleView.hidden = !active;
    _contentView.layer.borderWidth = (active) ? 1/_scale/self.screenScale : 0;
    _contentView.layer.cornerRadius = (active) ? 3/_scale/self.screenScale : 0;
    
    _contentView.layer.shadowColor = (active) ? [UIColor blackColor].CGColor : [UIColor clearColor].CGColor;
    
    _view.userInteractionEnabled = active;
}

- (void)setScale:(CGFloat)scale
{
    [self setScale:scale rotation:MAXFLOAT];
}

- (void)setScale:(CGFloat)scale rotation:(CGFloat)rotation
{
    if (rotation != MAXFLOAT) {
        _arg = rotation;
    }
    _scale = MIN(MAX(scale, _minScale), _maxScale);
    
    self.transform = CGAffineTransformIdentity;
    
    _contentView.transform = CGAffineTransformMakeScale(_scale, _scale);
    
    CGRect rct = self.frame;
    rct.origin.x += (rct.size.width - (_contentView.frame.size.width + LFMovingView_margin)) / 2;
    rct.origin.y += (rct.size.height - (_contentView.frame.size.height + LFMovingView_margin)) / 2;
    rct.size.width  = _contentView.frame.size.width + LFMovingView_margin;
    rct.size.height = _contentView.frame.size.height + LFMovingView_margin;
    self.frame = rct;
    
    _contentView.center = CGPointMake(rct.size.width/2, rct.size.height/2);
    _deleteButton.center = _contentView.frame.origin;
    _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
    
    self.transform = CGAffineTransformMakeRotation(_arg);

    if (_isActive) {        
        _contentView.layer.borderWidth = 1/_scale/self.screenScale;
        _contentView.layer.cornerRadius = 3/_scale/self.screenScale;
    }
}

- (void)setScreenScale:(CGFloat)screenScale
{
    _screenScale = screenScale;
    CGFloat scale = 1.f/screenScale;
    _deleteButton.transform = CGAffineTransformMakeScale(scale, scale);
    _circleView.transform = CGAffineTransformMakeScale(scale, scale);
    _deleteButton.center = _contentView.frame.origin;
    _circleView.center = CGPointMake(CGRectGetMaxX(_contentView.frame), CGRectGetMaxY(_contentView.frame));
}

- (CGFloat)scale
{
    return _scale;
}

- (CGFloat)rotation
{
    return _arg;
}

#pragma mark - Touch Event

- (void)pushedDeleteBtn:(id)sender
{
    /* 删除后寻找下一个活动视图
    LFMovingView *nextTarget = nil;
    
    const NSInteger index = [self.superview.subviews indexOfObject:self];
    
    for(NSInteger i=index+1; i<self.superview.subviews.count; ++i){
        UIView *view = [self.superview.subviews objectAtIndex:i];
        if([view isKindOfClass:[LFMovingView class]]){
            nextTarget = (LFMovingView *)view;
            break;
        }
    }
    
    if(nextTarget==nil){
        for(NSInteger i=index-1; i>=0; --i){
            UIView *view = [self.superview.subviews objectAtIndex:i];
            if([view isKindOfClass:[LFMovingView class]]){
                nextTarget = (LFMovingView *)view;
                break;
            }
        }
    }
    
    [[self class] setActiveEmoticonView:nextTarget];
     */
    [self cancelDeactivated];
    [self removeFromSuperview];
}

- (void)viewDidTap:(UITapGestureRecognizer*)sender
{
    if (self.tapEnded) self.tapEnded(self);
    [[self class] setActiveEmoticonView:self];
}

- (void)viewDidPan:(UIPanGestureRecognizer*)sender
{
    [[self class] setActiveEmoticonView:self];
    
    CGPoint p = [sender translationInView:self.superview];
    
    if(sender.state == UIGestureRecognizerStateBegan){
        _initialPoint = self.center;
        [self cancelDeactivated];
    }
    self.center = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        BOOL isMoveCenter = NO;
        CGRect rect = CGRectInset(self.frame, self.frame.size.width/2, self.frame.size.height/2);
        if (self.moveCenter) {
            isMoveCenter = self.moveCenter(rect);
        } else {
            isMoveCenter = !CGRectIntersectsRect(self.superview.frame, rect);
        }
        if (isMoveCenter) {
            /** 超出边界线 重置会中间 */
            [UIView animateWithDuration:0.25f animations:^{
                self.center = [self.superview convertPoint:[UIApplication sharedApplication].keyWindow.center fromView:(UIView *)[UIApplication sharedApplication].keyWindow];
            }];            
        }
        [self autoDeactivated];
    }
}

- (void)circleViewDidPan:(UIPanGestureRecognizer*)sender
{
    CGPoint p = [sender translationInView:self.superview];
    
    static CGFloat tmpR = 1;
    static CGFloat tmpA = 0;
    if(sender.state == UIGestureRecognizerStateBegan){
        [self cancelDeactivated];
        _initialPoint = [self.superview convertPoint:_circleView.center fromView:_circleView.superview];
        
        CGPoint p = CGPointMake(_initialPoint.x - self.center.x, _initialPoint.y - self.center.y);
        tmpR = sqrt(p.x*p.x + p.y*p.y);
        tmpA = atan2(p.y, p.x);
        
        _initialArg = _arg;
        _initialScale = _scale;
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self autoDeactivated];
    }
    
    p = CGPointMake(_initialPoint.x + p.x - self.center.x, _initialPoint.y + p.y - self.center.y);
    CGFloat R = sqrt(p.x*p.x + p.y*p.y);
    CGFloat arg = atan2(p.y, p.x);
    
    _arg = _initialArg + arg - tmpA;
    [self setScale:(_initialScale * R / tmpR)];
}

@end
