//
//  LFImagePickerEditingType.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/14.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#ifndef LFImagePickerEditingType_h
#define LFImagePickerEditingType_h

typedef NS_ENUM(NSUInteger, LFPhotoEditingType) {
    /** 绘画 */
    LFPhotoEditingType_draw = 0,
    /** 贴图 */
    LFPhotoEditingType_sticker,
    /** 文本 */
    LFPhotoEditingType_text,
    /** 模糊 */
    LFPhotoEditingType_splash,
    /** 修剪 */
    LFPhotoEditingType_crop,
};

typedef NS_ENUM(NSUInteger, LFVideoEditingType) {
    /** 绘画 */
    LFVideoEditingType_draw = 0,
    /** 贴图 */
    LFVideoEditingType_sticker,
    /** 文本 */
    LFVideoEditingType_text,
    /** 模糊 */
    LFVideoEditingType_splash,
    /** 修剪 */
    LFVideoEditingType_crop,
};

typedef NS_ENUM(NSUInteger, LFSplashStateType) {
    /** 马赛克 */
    LFSplashStateType_Mosaic,
    /** 高斯模糊 */
    LFSplashStateType_Blurry,
    /** 画笔涂抹 */
    LFSplashStateType_Paintbrush,
};

#endif /* LFImagePickerEditingType_h */
