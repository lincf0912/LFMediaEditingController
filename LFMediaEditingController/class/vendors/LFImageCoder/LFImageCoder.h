//
//  LFImageCoder.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/20.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** 参考YYImageCoder对图片解码 */

/**
图片解码

@param imageRef 图片
@param size 图片大小（根据大小与contentMode缩放图片，传入CGSizeZero不处理大小）
@param contentMode 内容布局（仅支持UIViewContentModeScaleAspectFill与UIViewContentModeScaleAspectFit，与size搭配）
@param orientation 图片方向（imageRef的方向，会自动更正为up，如果传入up则不更正）
@return 返回解码后的图片，如果失败，则返回NULL
*/
CG_EXTERN CGImageRef _Nullable LFIC_CGImageScaleDecodedFromCopy(CGImageRef imageRef, CGSize size, UIViewContentMode contentMode, UIImageOrientation orientation);

/**
图片解码

@param imageRef 图片
@return 返回解码后的图片，如果失败，则返回NULL
*/
CG_EXTERN CGImageRef _Nullable LFIC_CGImageDecodedFromCopy(CGImageRef imageRef);

/**
 图片解码

 @param image 图片
 @return 返回解码后的图片，如果失败，则返回NULL
 */
CG_EXTERN CGImageRef _Nullable LFIC_CGImageDecodedCopy(UIImage *image);

/**
 图片解码

 @param image 图片
 @return 返回解码后的图片，如果失败，则返回自身
 */
UIKIT_EXTERN UIImage * LFIC_UIImageDecodedCopy(UIImage *image);

NS_ASSUME_NONNULL_END
