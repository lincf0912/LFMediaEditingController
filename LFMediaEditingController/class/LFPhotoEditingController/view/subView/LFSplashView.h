//
//  LFSplashView_new.h
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/6/7.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFMediaEditingType.h"

@interface LFSplashView : UIView

/** 数据 */
@property (nonatomic, strong) NSDictionary *data;

/** 马赛克大小 */
@property (nonatomic, assign) CGFloat squareWidth;
/** 画笔大小 */
@property (nonatomic, assign) CGSize paintSize;
/** 正在绘画 */
@property (nonatomic, readonly) BOOL isDrawing;

@property (nonatomic, copy) void(^splashBegan)(void);
@property (nonatomic, copy) void(^splashEnded)(void);
/** 绘画颜色 */
@property (nonatomic, copy) UIColor *(^splashColor)(CGPoint point);

/** 改变模糊状态 */
@property (nonatomic, assign) LFSplashStateType state;

/** 是否可撤销 */
- (BOOL)canUndo;

//撤销
- (void)undo;

@end
