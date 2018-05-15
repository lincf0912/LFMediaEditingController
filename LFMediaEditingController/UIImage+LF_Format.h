//
//  UIImage+Format.h
//  MEMobile
//
//  Created by LamTsanFeng on 16/9/23.
//  Copyright © 2016年 GZMiracle. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LFImageType) {
    LFImageType_Unknow = 0,
    LFImageType_JPEG,
    LFImageType_JPEG2000,
    LFImageType_TIFF,
    LFImageType_BMP,
    LFImageType_ICO,
    LFImageType_ICNS,
    LFImageType_GIF,
    LFImageType_PNG,
    LFImageType_WebP,
};

CG_EXTERN LFImageType LFImageDetectType(CFDataRef data);

@interface UIImage (LF_Format)

/**
 *  @author lincf, 16-09-23 14:09:47
 *
 *  匹配加载 webp、gif、jpeg 等图片
 *
 *  @param imagePath 图片路径
 *
 *  @return UIImage
 */
+ (instancetype)LF_imageWithImagePath:(NSString *)imagePath;

+ (instancetype)LF_imageWithImagePath:(NSString *)imagePath error:(NSError **)error;

+ (instancetype)LF_imageWithImageData:(NSData *)imgData;
@end
