//
//  LFVideoEdit.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFVideoEdit : NSObject

/** 编辑封面 */
@property (nonatomic, readonly) UIImage *editPosterImage;
/** 编辑预览图片 */
@property (nonatomic, readonly) UIImage *editPreviewImage;
/** 编辑视频路径(最终) */
@property (nonatomic, readonly) NSURL *editFinalURL;
/** 编辑视频路径(原始) */
@property (nonatomic, readonly) NSURL *editURL;
/** 编辑数据 */
@property (nonatomic, readonly) NSDictionary *editData;

/** 初始化 */
- (instancetype)initWithEditURL:(NSURL *)editURL editFinalURL:(NSURL *)editFinalURL data:(NSDictionary *)data;
@end
