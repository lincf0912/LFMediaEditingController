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
/**
 * 以下属性仅对未编辑过对象生效，若是已经编辑过的对象（LFPhotoEdit）忽略该属性。
 * The following properties are only valid for unedited objects. If the object has been edited (LFPhotoEdit), the attribute is ignored.
 */

/**
 绘画的默认颜色
 The default color of the painting.
 
 NSNumber containing LFPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditDrawColorAttributeName;
/**
 自定义贴图资源路径，完整的资源路径目录file://...。将该目录下的所有后缀为@"png", @"jpg", @"jpeg", @"gif"的文件作为可选贴图，它完全代替了项目资源贴图。
 The sticker are customizable. This path must be a full path directory (for example: file://... ). All files with the suffix @"png", @"jpg", @"jpeg", @"gif" in the directory as stickers.
 
 NSString containing string path, default nil. sticker resource path.
 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditStickerAttributeName;
/**
 文字的默认颜色
 The default color of the text.
 
 NSNumber containing LFPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditTextColorAttributeName;
/**
 默认音轨是否静音🔇
 Set the default track mute🔇
 
 NSNumber containing BOOL, default false: default audioTrack ,true: mute.
 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditAudioMuteAttributeName;
/**
 自定义音轨资源路径，完整的资源路径目录file://...。将该目录下的所有文件作为可选音轨。它没有任何判断，请确保目录内的文件都是可播放的音频文件。
 The audio tracks are customizable. This path must be a full path directory (for example: file://... ). All files in the directory as audio tracks. It does not have any judgment logic, please make sure that the files in the directory are all playable audio files.
 
 NSArray containing NSURL(fileURLWithPath:), default nil. audio resource paths.
 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditAudioUrlsAttributeName;
/**
 滤镜的默认类型
 The default type of the filter.
 
 NSNumber containing LFPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditFilterAttributeName;
/**
 播放速率
 Play rate
 
 NSNumber containing double, default 1, Range of 0.5 to 2.0.
 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditRateAttributeName;
/**
 剪辑的最小时刻
 Minimum moment of the clip
 
 NSNumber containing double, default 1.0. Must be greater than 0 and less than LFVideoEditClipMaxDurationAttributeName, otherwise invalid. In general, it is an integer
 */
UIKIT_EXTERN LFVideoEditOperationStringKey const LFVideoEditClipMinDurationAttributeName;
/**
 剪辑的最大时刻
 Maximum moment of the clip
 
 NSNumber containing double, default 0. Must be greater than min, otherwise invalid. 0 is not limited. In general, it is an integer
 */
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
/**
 设置编辑图片->重新初始化
 Set edit photo -> init
 */
- (void)setVideoURL:(NSURL *)url placeholderImage:(UIImage *)image;
- (void)setVideoAsset:(AVAsset *)asset placeholderImage:(UIImage *)image;
/**
 设置编辑对象->重新编辑
 Set edit object -> re-edit
 */
@property (nonatomic, strong) LFVideoEdit *videoEdit;

/**
 设置操作类型
 The type of operation.
 default is LFPhotoEditOperationType_All
 */
@property (nonatomic, assign) LFVideoEditOperationType operationType;
/**
 设置默认的操作类型，可以选择最多2种操作，优先级以operationType类型为准。
 1、LFVideoEditOperationType_clip优于所有类型。所有类型可与LFVideoEditOperationType_clip搭配；
 2、LFVideoEditOperationType_clip以外的其它类型搭配以优先级排序仅显示1种。
 ps:当operationType 与 defaultOperationType 只有LFVideoEditOperationType_clip的情况，不会返回编辑界面，在剪切界面直接完成编辑。
 
 The default type of the operation. You can select max to 2 LFVideoEditOperationType, the priority is based on the operationType.
 1、LFVideoEditOperationType has the highest priority. All types can be paired with LFVideoEditOperationType_clip;
 2、Types other than LFVideoEditOperationType_clip are prioritized to get the first one.
 ps:When the operationType and defaultOperationType are only LFVideoEditOperationType_clip, the editing interface will not be returned, and editing will be completed directly in the clipping interface.
 default is 0
 */
@property (nonatomic, assign) LFVideoEditOperationType defaultOperationType;
/**
 操作属性设置，根据operationType类型提供的操作，对应不同的操作设置相应的默认值。
 The operation attribute is based on the operationType, and the corresponding default value is set for different operations.
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
