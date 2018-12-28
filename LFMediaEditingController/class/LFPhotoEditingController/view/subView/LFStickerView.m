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
#import "LFText.h"
#import "LFStickerLabel.h"

NSString *const kLFStickerViewData_movingView = @"LFStickerViewData_movingView";

NSString *const kLFStickerViewData_movingView_type = @"LFStickerViewData_movingView_type";
NSString *const kLFStickerViewData_movingView_content = @"LFStickerViewData_movingView_content";

NSString *const kLFStickerViewData_movingView_center = @"LFStickerViewData_movingView_center";
NSString *const kLFStickerViewData_movingView_scale = @"LFStickerViewData_movingView_scale";
NSString *const kLFStickerViewData_movingView_rotation = @"LFStickerViewData_movingView_rotation";


@interface LFStickerView ()

@property (nonatomic, weak) LFMovingView *selectMovingView;

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
    return (view == self ? nil : view);
}

- (void)setTapEnded:(void (^)(BOOL))tapEnded
{
    _tapEnded = tapEnded;
    for (LFMovingView *subView in self.subviews) {
        if ([subView isKindOfClass:[LFMovingView class]]) {
            if (tapEnded) {
                __weak typeof(self) weakSelf = self;
                [subView setTapEnded:^(LFMovingView *movingView, UIView *view, BOOL isActive) {
                    weakSelf.selectMovingView = movingView;
                    weakSelf.tapEnded(isActive);
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
- (UIImage *)getSelectStickerImage
{
    if (self.selectMovingView.type == LFMovingViewType_imageView) {
        return ((UIImageView *)self.selectMovingView.view).image;
    }
    return nil;
}
- (LFText *)getSelectStickerText
{
    if (self.selectMovingView.type == LFMovingViewType_label) {
        return ((LFStickerLabel *)self.selectMovingView.view).lf_text;
    }
    return nil;
}

/** 更改选中贴图内容 */
- (void)changeSelectStickerImage:(UIImage *)image
{
    if (self.selectMovingView.type == LFMovingViewType_imageView) {
        UIImageView *imageView = (UIImageView *)self.selectMovingView.view;
        imageView.image = image;
        [self.selectMovingView updateFrameWithViewSize:image.size];
    }
}
- (void)changeSelectStickerText:(LFText *)text
{
    if (self.selectMovingView.type == LFMovingViewType_label) {
        LFStickerLabel *label = (LFStickerLabel *)self.selectMovingView.view;
        label.lf_text = text;
        //阴影颜色
        label.layer.shadowColor = ([text.textColor isEqual:[UIColor blackColor]]) ? [UIColor whiteColor].CGColor : [UIColor blackColor].CGColor;
        [label drawText];
        [self.selectMovingView updateFrameWithViewSize:label.size];
    }
}

/** 创建可移动视图 */
- (LFMovingView *)createBaseMovingView:(UIView *)view active:(BOOL)active
{
    LFMovingViewType type = LFMovingViewType_unknown;
    if ([view isMemberOfClass:[UIImageView class]]) {
        type = LFMovingViewType_imageView;
    } else if ([view isMemberOfClass:[LFStickerLabel class]]) {
        type = LFMovingViewType_label;
    }
    
    LFMovingView *movingView = [[LFMovingView alloc] initWithView:view type:type];
    /** 屏幕中心 */
    movingView.center = [self convertPoint:[UIApplication sharedApplication].keyWindow.center fromView:(UIView *)[UIApplication sharedApplication].keyWindow];
    
    /** 最小缩放率 */
    movingView.minScale = self.minScale;
    /** 最大缩放率 额外调整最大缩放率的比例，比例以屏幕为标准。 */
    CGFloat diffScale = [UIScreen mainScreen].bounds.size.width / view.frame.size.width;
    movingView.maxScale = self.maxScale * diffScale;
    /** 屏幕缩放率 */
    movingView.screenScale = self.screenScale;
    
    [self addSubview:movingView];
    
    if (active) {
        [LFMovingView setActiveEmoticonView:movingView];
    }
    
    
    if (self.tapEnded) {
        __weak typeof(self) weakSelf = self;
        [movingView setTapEnded:^(LFMovingView *movingView, UIView *view, BOOL isActive) {
            weakSelf.selectMovingView = movingView;
            weakSelf.tapEnded(isActive);
        }];
    }
    if (self.moveCenter) {
        __weak typeof(self) weakSelf = self;
        [movingView setMoveCenter:^BOOL (CGRect rect) {
            return weakSelf.moveCenter(rect);
        }];
    }
    
    return movingView;
}

/** 创建图片 */
- (void)createImage:(UIImage *)image
{
    LFMovingView *movingView = [self doCreateImage:image active:YES];
    CGFloat ratio = MIN( (0.2 * [UIScreen mainScreen].bounds.size.width) / movingView.width, (0.5 * [UIScreen mainScreen].bounds.size.height) / movingView.height);
    CGFloat scale = ratio/self.screenScale;
    [movingView setScale:scale];
    self.selectMovingView = movingView;
}

- (LFMovingView *)doCreateImage:(UIImage *)image active:(BOOL)active
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    LFMovingView *movingView = [self createBaseMovingView:imageView active:active];
    
    return movingView;
}

/** 创建文字 */
- (void)createText:(LFText *)text
{
    LFMovingView *movingView = [self doCreateText:text active:YES];
    //    CGFloat ratio = MIN( (0.5 * self.width) / movingView.width, (0.5 * self.height) / movingView.height);
    CGFloat scale = 0.8f/self.screenScale;
    [movingView setScale:scale];
    self.selectMovingView = movingView;
}

- (LFMovingView *)doCreateText:(LFText *)text active:(BOOL)active
{
    CGFloat margin = 5.f;
    LFStickerLabel *label = [[LFStickerLabel alloc] initWithFrame:CGRectZero];
    /** 设置内边距 */
    label.textInsets = UIEdgeInsetsMake(margin, margin, margin, margin);
    label.lf_text = text;
    [label drawText];
    //阴影透明度
    label.layer.shadowOpacity = .8;
    //阴影宽度
    label.layer.shadowRadius = 3.0;
    //阴影颜色
    label.layer.shadowColor = ([text.textColor isEqual:[UIColor blackColor]]) ? [UIColor whiteColor].CGColor : [UIColor blackColor].CGColor;
    //映影偏移
    label.layer.shadowOffset = CGSizeMake(1, 1);
    
    LFMovingView *movingView = [self createBaseMovingView:label active:active];
    
    return movingView;
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

            if (view.type == LFMovingViewType_label) {
                LFStickerLabel *label = (LFStickerLabel *)view.view;
                [movingDatas addObject:@{kLFStickerViewData_movingView_type:@(view.type)
                                         , kLFStickerViewData_movingView_content:label.lf_text
                                         , kLFStickerViewData_movingView_scale:@(view.scale)
                                         , kLFStickerViewData_movingView_rotation:@(view.rotation)
                                         , kLFStickerViewData_movingView_center:[NSValue valueWithCGPoint:view.center]
                                         }];
            } else if (view.type == LFMovingViewType_imageView) {
                UIImageView *imageView = (UIImageView *)view.view;
                [movingDatas addObject:@{kLFStickerViewData_movingView_type:@(view.type)
                                         , kLFStickerViewData_movingView_content:imageView.image
                                         , kLFStickerViewData_movingView_scale:@(view.scale)
                                         , kLFStickerViewData_movingView_rotation:@(view.rotation)
                                         , kLFStickerViewData_movingView_center:[NSValue valueWithCGPoint:view.center]
                                         }];
            }
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
            
            LFMovingViewType type = [movingData[kLFStickerViewData_movingView_type] integerValue];
            id content = movingData[kLFStickerViewData_movingView_content];
            CGFloat scale = [movingData[kLFStickerViewData_movingView_scale] floatValue];
            CGFloat rotation = [movingData[kLFStickerViewData_movingView_rotation] floatValue];
            CGPoint center = [movingData[kLFStickerViewData_movingView_center] CGPointValue];
            
            LFMovingView *view = nil;
            if (type == LFMovingViewType_imageView) {
                view = [self doCreateImage:content active:NO];
            } else if (type == LFMovingViewType_label) {
                view = [self doCreateText:content active:NO];
            } else {
                continue;
            }
            [view setScale:scale rotation:rotation];
            view.center = center;
        }
    }
}

@end
