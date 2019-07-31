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
    /** 滤镜 */
    LFVideoEditOperationType_filter NS_ENUM_AVAILABLE_IOS(9_0) = 1 << 4,
    /** 速率 */
    LFVideoEditOperationType_rate = 1 << 5,
    /** 剪辑 */
    LFVideoEditOperationType_clip = 1 << 6,
    /** 所有 */
    LFVideoEditOperationType_All = ~0UL,
};

typedef NSString * LFVideoEditOperationStringKey NS_EXTENSIBLE_STRING_ENUM;
/************************ Attributes ************************/
/** NSNumber containing LFVideoEditOperationSubType, default 0 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditDrawColorAttributeName;
/** NSString containing string path, default nil. sticker resource path. */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditStickerAttributeName;
/** NSNumber containing LFVideoEditOperationSubType, default 0 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditTextColorAttributeName;
/** NSNumber containing BOOL, default false: default audioTrack ,true: mute. */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditAudioMuteAttributeName;
/** NSArray  containing NSURL(fileURLWithPath:), default nil. audio resource paths. */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditAudioUrlsAttributeName;
/** NSNumber containing LFVideoEditOperationSubType, default 0 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditFilterAttributeName;
/** NSNumber containing double, default 1, Range of 0.5 to 2.0. */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditRateAttributeName;
/** NSNumber containing double, default 1.0. Must be greater than 0 and less than LFVideoEditClipMaxDurationAttributeName, otherwise invalid. In general, it is an integer */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditClipMinDurationAttributeName;
/** NSNumber containing double, default 0. Must be greater than min, otherwise invalid. 0 is not limited. In general, it is an integer */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditClipMaxDurationAttributeName;
/************************ Attributes ************************/

typedef NS_ENUM(NSUInteger, LFVideoEditOperationSubType) {
    
    /** LFVideoEditOperationType_draw && LFVideoEditDrawColorAttributeName */
    
    LFVideoEditOperationSubTypeDrawWhiteColor = 1,
    LFVideoEditOperationSubTypeDrawBlackColor,
    LFVideoEditOperationSubTypeDrawRedColor,
    LFVideoEditOperationSubTypeDrawLightYellowColor,
    LFVideoEditOperationSubTypeDrawYellowColor,
    LFVideoEditOperationSubTypeDrawLightGreenColor,
    LFVideoEditOperationSubTypeDrawGreenColor,
    LFVideoEditOperationSubTypeDrawAzureColor,
    LFVideoEditOperationSubTypeDrawRoyalBlueColor,
    LFVideoEditOperationSubTypeDrawBlueColor,
    LFVideoEditOperationSubTypeDrawPurpleColor,
    LFVideoEditOperationSubTypeDrawLightPinkColor,
    LFVideoEditOperationSubTypeDrawVioletRedColor,
    LFVideoEditOperationSubTypeDrawPinkColor,
    
    /** LFVideoEditOperationType_text && LFVideoEditTextColorAttributeName */
    
    LFVideoEditOperationSubTypeTextWhiteColor = 100,
    LFVideoEditOperationSubTypeTextBlackColor,
    LFVideoEditOperationSubTypeTextRedColor,
    LFVideoEditOperationSubTypeTextLightYellowColor,
    LFVideoEditOperationSubTypeTextYellowColor,
    LFVideoEditOperationSubTypeTextLightGreenColor,
    LFVideoEditOperationSubTypeTextGreenColor,
    LFVideoEditOperationSubTypeTextAzureColor,
    LFVideoEditOperationSubTypeTextRoyalBlueColor,
    LFVideoEditOperationSubTypeTextBlueColor,
    LFVideoEditOperationSubTypeTextPurpleColor,
    LFVideoEditOperationSubTypeTextLightPinkColor,
    LFVideoEditOperationSubTypeTextVioletRedColor,
    LFVideoEditOperationSubTypeTextPinkColor,
    
    /** LFVideoEditOperationType_filter && LFVideoEditFilterAttributeName */
    
    LFVideoEditOperationSubTypeLinearCurveFilter = 400,
    LFVideoEditOperationSubTypeChromeFilter,
    LFVideoEditOperationSubTypeFadeFilter,
    LFVideoEditOperationSubTypeInstantFilter,
    LFVideoEditOperationSubTypeMonoFilter,
    LFVideoEditOperationSubTypeNoirFilter,
    LFVideoEditOperationSubTypeProcessFilter,
    LFVideoEditOperationSubTypeTonalFilter,
    LFVideoEditOperationSubTypeTransferFilter,
    LFVideoEditOperationSubTypeCurveLinearFilter,
    LFVideoEditOperationSubTypeInvertFilter,
    LFVideoEditOperationSubTypeMonochromeFilter,
    
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
/** 设置默认的操作类型(可以选择最多2种操作，优先级以operationType类型为准，但修剪类型优于所有。所有类型可与修剪类型搭配显示2种；修剪类型以外的其它多种类型搭配以优先级排序仅显示1种) default is 0
    ps:当operationType 与 defaultOperationType 只有LFVideoEditOperationType_clip的情况，不会返回编辑界面，在剪切界面直接完成编辑。
 */
@property (nonatomic, assign) LFVideoEditOperationType defaultOperationType;
/**
 操作属性设置
 根据operationType类型提供的操作，对应不同的操作设置相应的默认值。
 */
@property (nonatomic, strong) NSDictionary<LFVideoEditOperationStringKey, id> *operationAttrs;

/** 代理 */
@property (nonatomic, weak) id<LFVideoEditingControllerDelegate> delegate;

#pragma mark - deprecated
/** 允许剪辑的最小时长 1秒 */
@property (nonatomic, assign) double minClippingDuration __deprecated_msg("property deprecated. Use `operationAttrs[LFVideoEditClipMinDurationAttributeName]`");
/** 自定义音频资源（fileURLWithPath:） */
@property (nonatomic, strong) NSArray <NSURL *>*defaultAudioUrls __deprecated_msg("property deprecated. Use `operationAttrs[LFVideoEditAudioUrlsAttributeName]`");
/** 自定义贴图资源 */
@property (nonatomic, strong) NSString *stickerPath __deprecated_msg("property deprecated. Use `operationAttrs[LFVideoEditStickerAttributeName]`");

@end

@protocol LFVideoEditingControllerDelegate <NSObject>

- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didCancelPhotoEdit:(LFVideoEdit *)videoEdit;
- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didFinishPhotoEdit:(LFVideoEdit *)videoEdit;

@end
