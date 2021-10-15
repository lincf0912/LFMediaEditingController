//
//  LFPhotoEditingController.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/22.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFBaseEditingController.h"
#import "LFStickerContent.h"
#import "LFPhotoEdit.h"
#import "LFExtraAspectRatio.h"

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
/**
 * 以下属性仅对未编辑过对象生效，若是已经编辑过的对象（LFPhotoEdit）忽略该属性。
 * The following properties are only valid for unedited objects. If the object has been edited (LFPhotoEdit), the attribute is ignored.
 */

/**
 绘画的默认颜色
 The default color of the painting.
 
 NSNumber containing LFPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditDrawColorAttributeName;
/**
 绘画的默认笔刷
 The default brush of the painting.
 
 NSNumber containing LFPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditDrawBrushAttributeName;
/**
 自定义贴图资源路径，完整的资源路径目录file://...。将该目录下的所有后缀为@"png", @"jpg", @"jpeg", @"gif"的文件作为可选贴图，它完全代替了项目资源贴图。
 The sticker are customizable. This path must be a full path directory (for example: file://... ). All files with the suffix @"png", @"jpg", @"jpeg", @"gif" in the directory as stickers.
 
 NSString containing string path, default nil. sticker resource path.
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditStickerAttributeName __deprecated_msg("LFPhotoEditOperationStringKey deprecated. Use `LFPhotoEditStickerContentsAttributeName`");
/**
 详细请看LFStickerContent.h。
 所有资源不适宜过大。开发者需要把控数据大小。防止内存崩溃。
 
 See LFStickerContent.h for details.
 All resources should not be too large. Developers need to control the size of the data. Prevent memory crash.
 
 @{LFPhotoEditStickerContentsAttributeName:@[
    // 第一个标签的数据。
    // Data for the first tab.
    [LFStickerContent stickerContentWithTitle:@"Tab Name" contents:@[@"Tab Datas"]],
    // 第二个标签的数据。
    // Data for the second tab.
    [LFStickerContent stickerContentWithTitle:@"Tab Name" contents:@[@"Tab Datas"]],
    ......
 ]}
 
 NSArray containing NSArray<LFStickerContent *>, default
 @[
    [LFStickerContent stickerContentWithTitle:@"默认" contents:@[LFStickerContentDefaultSticker]],
    [LFStickerContent stickerContentWithTitle:@"相册" contents:@[LFStickerContentAllAlbum]]
 ].
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditStickerContentsAttributeName;
/**
 文字的默认颜色
 The default color of the text.
 
 NSNumber containing LFPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditTextColorAttributeName;
/**
 模糊的默认类型
 The default type of the blur.
 
 NSNumber containing LFPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditSplashAttributeName;
/**
 滤镜的默认类型
 The default type of the filter.
 
 NSNumber containing LFPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditFilterAttributeName;
/**
 默认剪切比例。如果是自定义比例，需要从LFPhotoEditOperationSubTypeCropAspectRatioOriginal开始计算。
 The default aspect ratio of the crop. If it is a custom aspect ratio. It needs to be calculated from LFPhotoEditOperationSubTypeCropAspectRatioOriginal (LFPhotoEditOperationSubTypeCropAspectRatioOriginal+index).
 
 NSNumber containing LFPhotoEditOperationSubType, default 0
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditCropAspectRatioAttributeName;
/**
 允许剪切旋转
Allow rotation.
 
 NSNumber containing LFPhotoEditOperationSubType, default YES
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditCropCanRotateAttributeName;
/**
 允许剪切比例。如果值为NO，剪切比例将不会被重置。（固定预设剪切比例）
 Allow aspect ratio. If the value is NO, the aspect ratio will not be reset.
 
 NSNumber containing LFPhotoEditOperationSubType, default YES
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditCropCanAspectRatioAttributeName;
/**
 自定义剪切比例。将会完全重写剪切比例，如需修改显示比例的名称可在LFImagePickerController.strings修改。
 Customize the aspect ratio. The aspect ratio will be rewritten. If you need to modify the name of the display, you can modify it in LFImagePickerController.strings.
 
 NSArray containing NSArray<id <LFExtraAspectRatioProtocol>>, default nil.
 ex:
 @[
    [LFExtraAspectRatio extraAspectRatioWithWidth:9 andHeight:16],
    [LFExtraAspectRatio extraAspectRatioWithWidth:2 andHeight:3],
 ].
 */
UIKIT_EXTERN LFPhotoEditOperationStringKey const LFPhotoEditCropExtraAspectRatioAttributeName;

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
    
    /** LFPhotoEditOperationType_draw && LFPhotoEditDrawBrushAttributeName */
    LFPhotoEditOperationSubTypeDrawPaintBrush = 50,
    LFPhotoEditOperationSubTypeDrawHighlightBrush,
    LFPhotoEditOperationSubTypeDrawChalkBrush,
    LFPhotoEditOperationSubTypeDrawFluorescentBrush,
    LFPhotoEditOperationSubTypeDrawStampAnimalBrush,
    LFPhotoEditOperationSubTypeDrawStampFruitBrush,
    LFPhotoEditOperationSubTypeDrawStampHeartBrush,
    
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
    LFPhotoEditOperationSubTypeSplashBlurry,
    LFPhotoEditOperationSubTypeSplashPaintbrush,
    
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
/**
 设置编辑图片->重新初始化
 Set edit photo -> init
 */
@property (nonatomic, strong) UIImage *editImage;

/**
 对GIF而言。editImage的每帧持续间隔是平均分配的，durations的每帧持续间隔是真实的。同时也会影响到最终生成的GIF数据。
 
 For GIF. The per-frame duration of the editImage is evenly distributed, and the per-frame duration of the durations is real. It also affects the final generated GIF data.
 
 NSError *error;
 durations = LFME_UIImageGIFDurationsFromData(imageData, &error);
 */
- (void)setEditImage:(UIImage *)editImage durations:(NSArray<NSNumber *> *)durations;

/**
 设置编辑对象->重新编辑
 Set edit object -> re-edit
 */
- (void)setPhotoEdit:(LFPhotoEdit *)photoEdit;

/**
 设置操作类型
 The type of operation.
 default is LFPhotoEditOperationType_All
 */
@property (nonatomic, assign) LFPhotoEditOperationType operationType;
/**
 设置默认的操作类型，可以选择最多2种操作，优先级以operationType类型为准。
 1、LFPhotoEditOperationType_crop优于所有类型。所有类型可与LFPhotoEditOperationType_crop搭配；
 2、LFPhotoEditOperationType_crop以外的其它类型搭配以优先级排序仅显示1种。
 ps:当operationType 与 defaultOperationType 只有LFPhotoEditOperationType_crop的情况，不会返回编辑界面，在剪切界面直接完成编辑。
 
 The default type of the operation. You can select max to 2 LFPhotoEditOperationType, the priority is based on the operationType.
 1、LFPhotoEditOperationType_crop has the highest priority. All types can be paired with LFPhotoEditOperationType_crop;
 2、Types other than LFPhotoEditOperationType_crop are prioritized to get the first one.
 ps:When the operationType and defaultOperationType are only LFPhotoEditOperationType_crop, the editing interface will not be returned, and editing will be completed directly in the cropping interface.
 default is 0
 */
@property (nonatomic, assign) LFPhotoEditOperationType defaultOperationType;
/**
 操作属性设置，根据operationType类型提供的操作，对应不同的操作设置相应的默认值。
 The operation attribute is based on the operationType, and the corresponding default value is set for different operations.
*/
@property (nonatomic, strong) NSDictionary<LFPhotoEditOperationStringKey, id> *operationAttrs;

/** 代理 */
@property (nonatomic, weak) id<LFPhotoEditingControllerDelegate> delegate;

#pragma mark - deprecated
/** 自定义贴图资源 */
@property (nonatomic, strong) NSString *stickerPath __deprecated_msg("property deprecated. Use `operationAttrs[LFPhotoEditStickerAttributeName]`");

@end

@protocol LFPhotoEditingControllerDelegate <NSObject>

- (void)lf_PhotoEditingControllerDidCancel:(LFPhotoEditingController *)photoEditingVC;
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit;
@optional
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit __deprecated_msg("delete deprecated. Use `lf_PhotoEditingControllerDidCancel:`");
@end
