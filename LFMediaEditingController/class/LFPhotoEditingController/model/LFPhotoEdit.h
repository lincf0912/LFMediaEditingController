//
//  LFPhotoEdit.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/23.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFPhotoEdit : NSObject

/** 编辑封面 */
@property (nonatomic, readonly) UIImage *editPosterImage;
/** 编辑预览图片 */
@property (nonatomic, readonly) UIImage *editPreviewImage;
/** 编辑图片数据 */
@property (nonatomic, readonly) NSData *editPreviewData;
/** 编辑GIF的每帧持续时间 */
@property (nonatomic, nullable, readonly) NSArray<NSNumber *> *durations;
/** 编辑原图片 */
@property (nonatomic, readonly) UIImage *editImage;
/** 编辑数据 */
@property (nonatomic, readonly) NSDictionary *editData;

/** 初始化 */
- (instancetype)initWithEditImage:(UIImage *)image previewImage:(UIImage *)previewImage data:(NSDictionary *)data;
/** 初始化-每帧带持续时间 */
- (instancetype)initWithEditImage:(UIImage *)image previewImage:(UIImage *)previewImage durations:(NSArray<NSNumber *> * __nullable)durations data:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
