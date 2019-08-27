//
//  LFStickerView.m
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/24.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFStickerView.h"
#import "LFMovingView.h"
#import "UIView+LFMEFrame.h"

NSString *const kLFStickerViewData_movingView = @"LFStickerViewData_movingView";

NSString *const kLFStickerViewData_movingView_content = @"LFStickerViewData_movingView_content";

NSString *const kLFStickerViewData_movingView_center = @"LFStickerViewData_movingView_center";
NSString *const kLFStickerViewData_movingView_scale = @"LFStickerViewData_movingView_scale";
NSString *const kLFStickerViewData_movingView_rotation = @"LFStickerViewData_movingView_rotation";


@interface LFStickerView ()

@property (nonatomic, weak) LFMovingView *selectMovingView;

@property (nonatomic, assign, getter=isHitTestSubView) BOOL hitTestSubView;

@end

@implementation LFStickerView

+ (void)LFStickerViewDeactivated
{
    [LFMovingView setActiveEmoticonView:nil];
}

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
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    _screenScale = 1.f;
    _minScale = .2f;
    _maxScale = 3.f;
}

#pragma mark - 解除响应事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    self.hitTestSubView = [view isDescendantOfView:self];
    return (view == self ? nil : view);
}

- (BOOL)isEnable
{
    return self.isHitTestSubView && self.selectMovingView.isActive;
}

- (void)setTapEnded:(void (^)(LFStickerItem *, BOOL))tapEnded
{
    _tapEnded = tapEnded;
    for (LFMovingView *subView in self.subviews) {
        if ([subView isKindOfClass:[LFMovingView class]]) {
            if (tapEnded) {
                __weak typeof(self) weakSelf = self;
                [subView setTapEnded:^(LFMovingView *view) {
                    weakSelf.selectMovingView = view;
                    weakSelf.tapEnded(view.item, view.isActive);
                }];
            } else {
                [subView setTapEnded:nil];
            }
        }
    }
}

- (void)setMoveCenter:(BOOL (^)(CGRect))moveCenter
{
    _moveCenter = moveCenter;
    for (LFMovingView *subView in self.subviews) {
        if ([subView isKindOfClass:[LFMovingView class]]) {
            if (moveCenter) {
                __weak typeof(self) weakSelf = self;
                [subView setMoveCenter:^BOOL (CGRect rect) {
                    return weakSelf.moveCenter(rect);
                }];
            } else {
                [subView setMoveCenter:nil];
            }
        }
    }
}

/** 激活选中的贴图 */
- (void)activeSelectStickerView
{
    [LFMovingView setActiveEmoticonView:self.selectMovingView];
}
/** 删除选中贴图 */
- (void)removeSelectStickerView
{
    [self.selectMovingView removeFromSuperview];
}

/** 获取选中贴图的内容 */
- (LFStickerItem *)getSelectStickerItem
{
    return self.selectMovingView.item;
}

/** 更改选中贴图内容 */
- (void)changeSelectStickerItem:(LFStickerItem *)item
{
    self.selectMovingView.item = item;
}

/** 创建可移动视图 */
- (LFMovingView *)createBaseMovingView:(LFStickerItem *)item active:(BOOL)active
{
    
    LFMovingView *movingView = [[LFMovingView alloc] initWithItem:item];
    /** 屏幕中心 */
    movingView.center = [self convertPoint:[UIApplication sharedApplication].keyWindow.center fromView:(UIView *)[UIApplication sharedApplication].keyWindow];
    
    [self updateMovingView:movingView];
    
    [self addSubview:movingView];
    
    if (active) {
        [LFMovingView setActiveEmoticonView:movingView];
    }
    
    
    __weak typeof(self) weakSelf = self;
    if (self.tapEnded) {
        [movingView setTapEnded:^(LFMovingView * _Nonnull view) {
            weakSelf.selectMovingView = view;
            weakSelf.tapEnded(view.item, view.isActive);
        }];
    }
    
    if (self.moveCenter) {
        [movingView setMoveCenter:^BOOL (CGRect rect) {
            return weakSelf.moveCenter(rect);
        }];
    }
    
    return movingView;
}

- (void)createStickerItem:(LFStickerItem *)item
{
    LFMovingView *movingView = [self createBaseMovingView:item active:YES];
    CGFloat ratio = 0.5;
    CGFloat scale = MIN( (ratio * [UIScreen mainScreen].bounds.size.width) / movingView.view.frame.size.width, (ratio * [UIScreen mainScreen].bounds.size.height) / movingView.view.frame.size.height);
    [movingView setScale:scale/self.screenScale];
//    NSLog(@"minScale:%f, maxScale:%f, scale:%f", movingView.minScale, movingView.maxScale, movingView.scale);
    
    self.selectMovingView = movingView;
}

- (void)updateMovingView:(LFMovingView *)movingView
{
    /** 最小缩放率 */
    movingView.minScale = self.minScale;
    /** 最大缩放率 */
    movingView.maxScale = self.maxScale;
    /** 屏幕缩放率 */
    movingView.screenScale = self.screenScale;
}


- (void)setScreenScale:(CGFloat)screenScale
{
    if (screenScale > 0) {
        _screenScale = screenScale;
        for (LFMovingView *subView in self.subviews) {
            if ([subView isKindOfClass:[LFMovingView class]]) {
                subView.screenScale = screenScale;
            }
        }
    }
}

#pragma mark  - 数据
- (NSDictionary *)data
{
    NSMutableArray *movingDatas = [@[] mutableCopy];
    for (LFMovingView *view in self.subviews) {
        if ([view isKindOfClass:[LFMovingView class]]) {

            [movingDatas addObject:@{kLFStickerViewData_movingView_content:view.item
                                     , kLFStickerViewData_movingView_scale:@(view.scale)
                                     , kLFStickerViewData_movingView_rotation:@(view.rotation)
                                     , kLFStickerViewData_movingView_center:[NSValue valueWithCGPoint:view.center]
                                     }];
        }
    }
    if (movingDatas.count) {
        return @{kLFStickerViewData_movingView:[movingDatas copy]};
    }
    return nil;
}

- (void)setData:(NSDictionary *)data
{
    NSArray *movingDatas = data[kLFStickerViewData_movingView];
    if (movingDatas.count) {
        for (NSDictionary *movingData in movingDatas) {
            
            
            LFStickerItem *item = movingData[kLFStickerViewData_movingView_content];
            CGFloat scale = [movingData[kLFStickerViewData_movingView_scale] floatValue];
            CGFloat rotation = [movingData[kLFStickerViewData_movingView_rotation] floatValue];
            CGPoint center = [movingData[kLFStickerViewData_movingView_center] CGPointValue];
            
            LFMovingView *view = [self createBaseMovingView:item active:NO];
            [view setScale:scale rotation:rotation];
            view.center = center;
        }
    }
}

@end
