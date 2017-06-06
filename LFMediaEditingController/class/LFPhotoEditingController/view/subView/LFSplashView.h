//
//  LFSplashView.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/28.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LFSplashStateType) {
    /** 马赛克 */
    LFSplashStateType_Mosaic,
    LFSplashStateType_Blurry,
};

@interface LFSplashView : UIView

/** 设置图片 */
- (void)setImage:(UIImage *)image mosaicLevel:(NSUInteger)level;

/** 原图 */
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSUInteger level;

/** 数据 */
@property (nonatomic, strong) NSDictionary *data;

@property (nonatomic, copy) void(^splashBegan)();
@property (nonatomic, copy) void(^splashEnded)();

/** 改变模糊状态 */
@property (nonatomic, assign) LFSplashStateType state;

/** 是否可撤销 */
- (BOOL)canUndo;

//撤销
- (void)undo;

@end
