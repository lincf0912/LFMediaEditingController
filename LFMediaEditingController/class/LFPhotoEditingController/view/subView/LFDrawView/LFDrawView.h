//
//  LFDrawView.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/2/23.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFBrush.h"

@interface LFDrawView : UIView

/** 画笔 */
@property (nonatomic, strong) LFBrush *brush;
/** 正在绘画 */
@property (nonatomic, readonly) BOOL isDrawing;
/** 图层数量 */
@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, copy) void(^drawBegan)(void);
@property (nonatomic, copy) void(^drawEnded)(void);

/** 数据 */
@property (nonatomic, strong) NSDictionary *data;

/** 是否可撤销 */
- (BOOL)canUndo;
//撤销
- (void)undo;

@end
