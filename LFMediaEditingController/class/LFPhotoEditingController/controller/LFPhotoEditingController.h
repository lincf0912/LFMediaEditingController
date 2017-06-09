//
//  LFPhotoEditingController.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/22.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFBaseEditingController.h"
#import "LFPhotoEdit.h"

@protocol LFPhotoEditingControllerDelegate;

@interface LFPhotoEditingController : LFBaseEditingController
/** 设置编辑图片->重新初始化 */
@property (nonatomic, strong) UIImage *editImage;
/** 设置编辑对象->重新编辑 */
@property (nonatomic, strong) LFPhotoEdit *photoEdit;

/** 代理 */
@property (nonatomic, weak) id<LFPhotoEditingControllerDelegate> delegate;

@end

@protocol LFPhotoEditingControllerDelegate <NSObject>

- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit;
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit;

@end
