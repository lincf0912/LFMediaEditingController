//
//  LFVideoEditingController.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "LFBaseEditingController.h"
#import "LFVideoEdit.h"

typedef NS_ENUM(NSUInteger, LFVideoEditOperationType) {
    /** 绘画 */
    LFVideoEditOperationType_draw = 1 << 0,
    /** 贴图 */
    LFVideoEditOperationType_sticker = 1 << 1,
    /** 文本 */
    LFVideoEditOperationType_text = 1 << 2,
    /** 音频 */
    LFVideoEditOperationType_audio = 1 << 3,
    /** 剪辑 */
    LFVideoEditOperationType_clip = 1 << 4,
    /** 所有 */
    LFVideoEditOperationType_All = ~0UL,
};

@protocol LFVideoEditingControllerDelegate;

@interface LFVideoEditingController : LFBaseEditingController

/** 编辑视频 */
@property (nonatomic, readonly) UIImage *placeholderImage;
@property (nonatomic, readonly) AVAsset *asset;
/** 设置编辑对象->重新编辑 */
@property (nonatomic, strong) LFVideoEdit *videoEdit;
/** 设置编辑视频路径->重新初始化 */
- (void)setVideoURL:(NSURL *)url placeholderImage:(UIImage *)image;
- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image;

/** 设置操作类型 default is LFVideoEditOperationType_All */
@property (nonatomic, assign) LFVideoEditOperationType operationType;
/** 设置默认的操作类型(可以选择最多2种操作，优先级以类型为准，但剪辑类型优于所有。所有类型可与剪辑类型搭配显示2种；剪辑以外的其它多种类型搭配以优先级排序仅显示1种) default is 0 */
@property (nonatomic, assign) LFVideoEditOperationType defaultOperationType;
/** 自定义贴图资源 */
@property (nonatomic, strong) NSString *stickerPath;
/** 允许剪辑的最小时长 1秒 */
@property (nonatomic, assign) double minClippingDuration;

/** 代理 */
@property (nonatomic, weak) id<LFVideoEditingControllerDelegate> delegate;

@end

@protocol LFVideoEditingControllerDelegate <NSObject>

- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didCancelPhotoEdit:(LFVideoEdit *)videoEdit;
- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didFinishPhotoEdit:(LFVideoEdit *)videoEdit;

@end
