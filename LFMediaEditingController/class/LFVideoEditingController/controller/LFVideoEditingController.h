//
//  LFVideoEditingController.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFBaseEditingController.h"
#import "LFVideoEdit.h"

@protocol LFVideoEditingControllerDelegate;

@interface LFVideoEditingController : LFBaseEditingController

/** 编辑视频路径 */
@property (nonatomic, readonly) NSURL *editURL;
@property (nonatomic, readonly) UIImage *placeholderImage;
/** 设置编辑对象->重新编辑 */
@property (nonatomic, strong) LFVideoEdit *videoEdit;

/** 代理 */
@property (nonatomic, weak) id<LFVideoEditingControllerDelegate> delegate;

/** 设置编辑视频路径->重新初始化 */
- (void)setVideoURL:(NSURL *)url placeholderImage:(UIImage *)image;
@end

@protocol LFVideoEditingControllerDelegate <NSObject>

- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didCancelPhotoEdit:(LFVideoEdit *)videoEdit;
- (void)lf_VideoEditingController:(LFVideoEditingController *)videoEditingVC didFinishPhotoEdit:(LFVideoEdit *)videoEdit;

@end
