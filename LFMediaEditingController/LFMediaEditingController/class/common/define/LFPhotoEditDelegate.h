//
//  LFPhotoEditDelegate.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

/** +++++++++++++++++++++绘画代理+++++++++++++++++++++ */
@protocol LFPhotoEditDrawDelegate <NSObject>
@optional
/** 开始绘画 */
- (void)lf_photoEditDrawBegan;
/** 结束绘画 */
- (void)lf_photoEditDrawEnded;
@end

/** +++++++++++++++++++++贴图代理+++++++++++++++++++++ */
@protocol LFPhotoEditStickerDelegate <NSObject>
@optional
/** 点击贴图 isActive=YES 选中的情况下点击，可以通过getSelectSticker获取选中贴图 */
- (void)lf_photoEditStickerDidSelectViewIsActive:(BOOL)isActive;
/** 贴图移动开始，可以通过getSelectSticker获取选中贴图 */
- (void)lf_photoEditStickerMovingBegan;
/** 贴图移动结束，可以通过getSelectSticker获取选中贴图 */
- (void)lf_photoEditStickerMovingEnded;

@end

/** +++++++++++++++++++++模糊代理+++++++++++++++++++++ */
@protocol LFPhotoEditSplashDelegate <NSObject>
@optional
/** 开始模糊 */
- (void)lf_photoEditSplashBegan;
/** 结束模糊 */
- (void)lf_photoEditSplashEnded;
@end

@protocol LFPhotoEditDelegate <LFPhotoEditDrawDelegate, LFPhotoEditStickerDelegate, LFPhotoEditSplashDelegate>

@end
