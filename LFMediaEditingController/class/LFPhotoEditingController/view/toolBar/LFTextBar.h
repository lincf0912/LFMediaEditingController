//
//  LFTextBar.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/22.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFTextBarDelegate;

@class LFText;
@interface LFTextBar : UIView

/** 需要显示的文字 */
@property (nonatomic, copy) LFText *showText;

/** 样式 */
@property (nonatomic, strong) UIColor *oKButtonTitleColorNormal;

/** 代理 */
@property (nonatomic, weak) id<LFTextBarDelegate> delegate;

@end

@protocol LFTextBarDelegate <NSObject>

/** 完成回调 */
- (void)lf_textBarController:(LFTextBar *)textBar didFinishText:(LFText *)text;
/** 取消回调 */
- (void)lf_textBarControllerDidCancel:(LFTextBar *)textBar;

@end
