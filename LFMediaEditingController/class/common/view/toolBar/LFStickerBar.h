//
//  LFStickerBar.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/21.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFStickerContent.h"

extern CGFloat const lf_stickerSize;
extern CGFloat const lf_stickerMargin;

@protocol LFStickerBarDelegate;

@interface LFStickerBar : UIView;

@property (nonatomic, weak) id <LFStickerBarDelegate> delegate;

/** 缓存数据，可避免下次重新加载时触发的网络处理 */
@property (nonatomic, strong) id cacheResources;

/**
 初始化 指定贴图资源目录

 @param frame 位置
 @param resources 贴图资源
 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame resources:(NSArray <LFStickerContent *>*)resources;

/// 初始化 缓存贴图资源
/// @param frame 位置
/// @param cacheResources 缓存数据
- (instancetype)initWithFrame:(CGRect)frame cacheResources:(id)cacheResources;

@end

@protocol LFStickerBarDelegate <NSObject>

- (void)lf_stickerBar:(LFStickerBar *)lf_stickerBar didSelectImage:(UIImage *)image;

@end
