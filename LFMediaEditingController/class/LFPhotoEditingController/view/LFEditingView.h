//
//  LFEditingView.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/10.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFScrollView.h"
#import "LFEditingProtocol.h"

@protocol LFEditingViewDelegate;

@interface LFEditingView : LFScrollView <LFEditingProtocol>

@property (nonatomic, strong) UIImage *image;
- (void)setImage:(UIImage *)image durations:(NSArray <NSNumber *> *)durations;

/** 代理 */
@property (nonatomic, weak) id<LFEditingViewDelegate> clippingDelegate;

/** 最小尺寸 CGSizeMake(80, 80) */
@property (nonatomic, assign) CGSize clippingMinSize;
/** 最大尺寸 CGRectInset(self.bounds , 20, 20) */
@property (nonatomic, assign) CGRect clippingMaxRect;

/** 开关编辑模式 */
@property (nonatomic, assign, getter=isClipping) BOOL clipping;
- (void)setClipping:(BOOL)clipping animated:(BOOL)animated;

/** 取消剪裁 */
- (void)cancelClipping:(BOOL)animated;
/** 还原 isClipping=YES 的情况有效 */
- (void)reset;
- (BOOL)canReset;
/** 旋转 isClipping=YES 的情况有效 */
- (void)rotate;
/** 默认长宽比例 */
@property (nonatomic, assign) NSUInteger defaultAspectRatioIndex;
/**
 固定长宽比例
 若为true，以下方法将失效：
 1、aspectRatioDescs;
 2、setAspectRatioIndex:
 3、aspectRatioIndex;
 */
@property (nonatomic, assign) BOOL fixedAspectRatio;
/** 长宽比例 */
- (NSArray <NSString *>*)aspectRatioDescs;
- (void)setAspectRatioIndex:(NSUInteger)aspectRatioIndex;
- (NSUInteger)aspectRatioIndex;

/** 创建编辑图片 */
- (void)createEditImage:(void (^)(UIImage *editImage))complete;

@end


@protocol LFEditingViewDelegate <NSObject>
/** 开始编辑目标 */
- (void)lf_EditingViewWillBeginEditing:(LFEditingView *)EditingView;
/** 停止编辑目标 */
- (void)lf_EditingViewDidEndEditing:(LFEditingView *)EditingView;

@optional
/** 即将进入剪切界面 */
- (void)lf_EditingViewWillAppearClip:(LFEditingView *)EditingView;
/** 进入剪切界面 */
- (void)lf_EditingViewDidAppearClip:(LFEditingView *)EditingView;
/** 即将离开剪切界面 */
- (void)lf_EditingViewWillDisappearClip:(LFEditingView *)EditingView;
/** 离开剪切界面 */
- (void)lf_EditingViewDidDisappearClip:(LFEditingView *)EditingView;

@end
