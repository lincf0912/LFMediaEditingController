//
//  NSObject+LFTipsGuideView.h
//  LFTipsGuideView
//
//  Created by TsanFeng Lam on 2020/2/4.
//  Copyright © 2020 lincf0912. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (LFTipsGuideView)

/// 弹出提示界面
/// @param view 在某个视图上。建议在keywindow。
/// @param views 需要提示的目标视图集合。
/// @param tipsArr 提示内容集合
- (void)lf_showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr;

/// 弹出提示界面
/// @param view 在某个视图上。建议在keywindow。
/// @param views 需要提示的目标视图集合。
/// @param tipsArr 提示内容集合
/// @param times 提示次数
- (void)lf_showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times;

/// 弹出提示界面
/// @param view 在某个视图上。建议在keywindow。
/// @param rects 需要提示的目标位置集合
/// @param tipsArr 提示内容集合
- (void)lf_showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr;

/// 弹出提示界面
/// @param view 在某个视图上。建议在keywindow。
/// @param rects 需要提示的目标位置集合
/// @param tipsArr 提示内容集合
/// @param times 提示次数
- (void)lf_showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times;

@end

NS_ASSUME_NONNULL_END
