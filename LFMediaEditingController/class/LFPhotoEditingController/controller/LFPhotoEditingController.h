//
//  LFPhotoEditingController.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/22.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFBaseEditingController.h"
#import "LFPhotoEdit.h"

typedef NS_ENUM(NSUInteger, LFPhotoEditOperationType) {
    /** 绘画 */
    LFPhotoEditOperationType_draw = 1 << 0,
    /** 贴图 */
    LFPhotoEditOperationType_sticker = 1 << 1,
    /** 文本 */
    LFPhotoEditOperationType_text = 1 << 2,
    /** 模糊 */
    LFPhotoEditOperationType_splash = 1 << 3,
    /** 滤镜 */
    LFPhotoEditOperationType_filter NS_ENUM_AVAILABLE_IOS(9_0) = 1 << 4,
    /** 修剪 */
    LFPhotoEditOperationType_crop = 1 << 5,
    /** 所有 */
    LFPhotoEditOperationType_All = ~0UL,
};

typedef NSString * LFPhotoEditOperationStringKey NS_EXTENSIBLE_STRING_ENUM;
/************************ Attributes ************************/
/** 绘画颜色 NSNumber containing LFPhotoEditOperationSubType, default 0 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditDrawColorAttributeName;
/** 自定义贴图资源路径 NSString containing string path, default nil. sticker resource path. */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditStickerAttributeName;
/** 文字颜色 NSNumber containing LFPhotoEditOperationSubType, default 0 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditTextColorAttributeName;
/** 模糊类型 NSNumber containing LFPhotoEditOperationSubType, default 0 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditSplashAttributeName;
/** 滤镜类型 NSNumber containing LFPhotoEditOperationSubType, default 0 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditFilterAttributeName;
/** 剪切比例 NSNumber containing LFPhotoEditOperationSubType, default 0 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditCropAspectRatioAttributeName;
/** 允许剪切旋转 NSNumber containing LFPhotoEditOperationSubType, default YES */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditCropCanRotateAttributeName;
/** 允许剪切比例 NSNumber containing LFPhotoEditOperationSubType, default YES */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditCropCanAspectRatioAttributeName;

/************************ Attributes ************************/

typedef NS_ENUM(NSUInteger, LFPhotoEditOperationSubType) {
    
    /** LFPhotoEditOperationType_draw && LFPhotoEditDrawColorAttributeName */
    
    LFPhotoEditOperationSubTypeDrawWhiteColor = 1,
    LFPhotoEditOperationSubTypeDrawBlackColor,
    LFPhotoEditOperationSubTypeDrawRedColor,
    LFPhotoEditOperationSubTypeDrawLightYellowColor,
    LFPhotoEditOperationSubTypeDrawYellowColor,
    LFPhotoEditOperationSubTypeDrawLightGreenColor,
    LFPhotoEditOperationSubTypeDrawGreenColor,
    LFPhotoEditOperationSubTypeDrawAzureColor,
    LFPhotoEditOperationSubTypeDrawRoyalBlueColor,
    LFPhotoEditOperationSubTypeDrawBlueColor,
    LFPhotoEditOperationSubTypeDrawPurpleColor,
    LFPhotoEditOperationSubTypeDrawLightPinkColor,
    LFPhotoEditOperationSubTypeDrawVioletRedColor,
    LFPhotoEditOperationSubTypeDrawPinkColor,
    
    /** LFPhotoEditOperationType_text && LFPhotoEditTextColorAttributeName */
    
    LFPhotoEditOperationSubTypeTextWhiteColor = 100,
    LFPhotoEditOperationSubTypeTextBlackColor,
    LFPhotoEditOperationSubTypeTextRedColor,
    LFPhotoEditOperationSubTypeTextLightYellowColor,
    LFPhotoEditOperationSubTypeTextYellowColor,
    LFPhotoEditOperationSubTypeTextLightGreenColor,
    LFPhotoEditOperationSubTypeTextGreenColor,
    LFPhotoEditOperationSubTypeTextAzureColor,
    LFPhotoEditOperationSubTypeTextRoyalBlueColor,
    LFPhotoEditOperationSubTypeTextBlueColor,
    LFPhotoEditOperationSubTypeTextPurpleColor,
    LFPhotoEditOperationSubTypeTextLightPinkColor,
    LFPhotoEditOperationSubTypeTextVioletRedColor,
    LFPhotoEditOperationSubTypeTextPinkColor,
    
    /** LFPhotoEditOperationType_splash && LFPhotoEditSplashAttributeName */
    
    LFPhotoEditOperationSubTypeSplashMosaic = 300,
    LFPhotoEditOperationSubTypeSplashPaintbrush = 301,
    
    /** LFPhotoEditOperationType_filter && LFPhotoEditFilterAttributeName */
    
    LFPhotoEditOperationSubTypeLinearCurveFilter = 400,
    LFPhotoEditOperationSubTypeChromeFilter,
    LFPhotoEditOperationSubTypeFadeFilter,
    LFPhotoEditOperationSubTypeInstantFilter,
    LFPhotoEditOperationSubTypeMonoFilter,
    LFPhotoEditOperationSubTypeNoirFilter,
    LFPhotoEditOperationSubTypeProcessFilter,
    LFPhotoEditOperationSubTypeTonalFilter,
    LFPhotoEditOperationSubTypeTransferFilter,
    LFPhotoEditOperationSubTypeCurveLinearFilter,
    LFPhotoEditOperationSubTypeInvertFilter,
    LFPhotoEditOperationSubTypeMonochromeFilter,
    
    /** LFPhotoEditOperationType_crop && LFPhotoEditCropAspectRatioAttributeName */
    
    LFPhotoEditOperationSubTypeCropAspectRatioOriginal = 500,
    LFPhotoEditOperationSubTypeCropAspectRatio1x1,
    LFPhotoEditOperationSubTypeCropAspectRatio3x2,
    LFPhotoEditOperationSubTypeCropAspectRatio4x3,
    LFPhotoEditOperationSubTypeCropAspectRatio5x3,
    LFPhotoEditOperationSubTypeCropAspectRatio15x9,
    LFPhotoEditOperationSubTypeCropAspectRatio16x9,
    LFPhotoEditOperationSubTypeCropAspectRatio16x10,
};

@protocol LFPhotoEditingControllerDelegate;

@interface LFPhotoEditingController : LFBaseEditingController
/** 设置编辑图片->重新初始化 */
@property (nonatomic, strong) UIImage *editImage;
/** 设置编辑对象->重新编辑 */
@property (nonatomic, strong) LFPhotoEdit *photoEdit;

/** 设置操作类型 default is LFPhotoEditOperationType_All */
@property (nonatomic, assign) LFPhotoEditOperationType operationType;
/** 设置默认的操作类型(可以选择最多2种操作，优先级以operationType类型为准，但修剪类型优于所有。所有类型可与修剪类型搭配显示2种；修剪类型以外的其它多种类型搭配以优先级排序仅显示1种) default is 0
    ps:当operationType 与 defaultOperationType 只有LFPhotoEditOperationType_crop的情况，不会返回编辑界面，在剪切界面直接完成编辑。
 */
@property (nonatomic, assign) LFPhotoEditOperationType defaultOperationType;
/**
 操作属性设置
    根据operationType类型提供的操作，对应不同的操作设置相应的默认值。
*/
@property (nonatomic, strong) NSDictionary<LFPhotoEditOperationStringKey, id> *operationAttrs;

/** 代理 */
@property (nonatomic, weak) id<LFPhotoEditingControllerDelegate> delegate;

#pragma mark - deprecated
/** 自定义贴图资源 */
@property (nonatomic, strong) NSString *stickerPath __deprecated_msg("property deprecated. Use `operationAttrs[LFPhotoEditStickerAttributeName]`");

@end

@protocol LFPhotoEditingControllerDelegate <NSObject>

- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit;
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit;

@end
