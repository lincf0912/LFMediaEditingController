//
//  LFClipToolbar.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/4/13.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LFClipToolbarDelegate, LFEditToolbarDataSource;

@interface LFClipToolbar : UIView

/** 代理 */
@property (nonatomic, weak) id<LFClipToolbarDelegate> delegate;
@property (nonatomic, weak) id<LFEditToolbarDataSource> dataSource;

/** 开启重置按钮 default NO  */
@property (nonatomic, assign) BOOL enableReset;

/** 选中长宽比例按钮 default NO */
@property (nonatomic, assign) BOOL selectAspectRatio;

@property (nonatomic, readonly) CGRect clickViewRect;

@end

@protocol LFClipToolbarDelegate <NSObject>

/** 取消 */
- (void)lf_clipToolbarDidCancel:(LFClipToolbar *)clipToolbar;
/** 完成 */
- (void)lf_clipToolbarDidFinish:(LFClipToolbar *)clipToolbar;
/** 重置 */
- (void)lf_clipToolbarDidReset:(LFClipToolbar *)clipToolbar;
/** 旋转 */
- (void)lf_clipToolbarDidRotate:(LFClipToolbar *)clipToolbar;
/** 长宽比例 */
- (void)lf_clipToolbarDidAspectRatio:(LFClipToolbar *)clipToolbar;

@end



@protocol LFEditToolbarDataSource <NSObject>

@optional
/** 允许旋转 默认YES */
- (BOOL)lf_clipToolbarCanRotate:(LFClipToolbar *)clipToolbar;
/** 允许长宽比例 默认YES */
- (BOOL)lf_clipToolbarCanAspectRatio:(LFClipToolbar *)clipToolbar;

@end
