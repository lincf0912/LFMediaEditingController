//
//  LFZoomingView.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/16.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFEditingProtocol.h"

@interface LFZoomingView : UIView <LFEditingProtocol>

@property (nonatomic, strong) UIImage *image;
- (void)setImage:(UIImage *)image durations:(NSArray <NSNumber *> *)durations;

/** 获取除图片以外的编辑图层 */
- (UIImage *)editOtherImagesInRect:(CGRect)rect rotate:(CGFloat)rotate;

/** 贴图是否需要移到屏幕中心 */
@property (nonatomic, copy) BOOL(^moveCenter)(CGRect rect);
@end

