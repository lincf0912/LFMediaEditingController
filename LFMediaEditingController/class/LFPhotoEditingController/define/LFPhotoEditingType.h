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

#endif /* LFImagePickerEditingType_h */
