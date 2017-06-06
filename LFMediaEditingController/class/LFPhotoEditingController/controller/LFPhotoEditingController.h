//
//  LFPhotoEditingController.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/22.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFPhotoEdit.h"

@protocol LFPhotoEditingControllerDelegate;

@interface LFPhotoEditingController : UIViewController
/** 设置编辑图片->重新初始化 */
@property (nonatomic, strong) UIImage *editImage;
/** 设置编辑对象->重新编辑 */
@property (nonatomic, strong) LFPhotoEdit *photoEdit;

/** 代理 */
@property (nonatomic, weak) id<LFPhotoEditingControllerDelegate> delegate;

/** 是否隐藏状态 默认YES */
@property (nonatomic, assign) BOOL isHiddenStatusBar;

/// 自定义外观颜色
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;
@property (nonatomic, strong) UIColor *cancelButtonTitleColorNormal;
/// 自定义文字
@property (nonatomic, copy) NSString *processHintStr;

@end

@protocol LFPhotoEditingControllerDelegate <NSObject>

- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didCancelPhotoEdit:(LFPhotoEdit *)photoEdit;
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit;

@end
