//
//  UIViewController+LFPresentation.h
//  HelloOC
//
//  Created by TsanFeng Lam on 2019/10/14.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (LFPresentation)

/**
 iOS13 UIModalPresentationPageSheet 的下拉滑动手势，彻底关闭（lf_dropShadowPanGestureRecognizer.enable = NO）。
 值得注意的是：它在viewDidAppear（含）之后才能获取值；在viewDidDisappear（含）之后无法获取值。
 正常使用：
 
 - (void)viewDidAppear:(BOOL)animated
 {
     [super viewDidAppear:animated];
     if (@available(iOS 13.0, *)) {
         if (isiPhone && self.navigationController.modalPresentationStyle == UIModalPresentationPageSheet) {
             // 不允许下拉关闭
             self.modalInPresentation = YES;
             // 彻底关闭下拉手势
             self.lf_dropShadowPanGestureRecognizer.enabled = NO;
         }
     }
 }

 - (void)viewWillDisappear:(BOOL)animated
 {
     [super viewWillDisappear:animated];
     if (@available(iOS 13.0, *)) {
         // 重新开启下拉手势
         self.lf_dropShadowPanGestureRecognizer.enabled = YES;
     }
 }
 
 */
@property (nonatomic, readonly) UIPanGestureRecognizer *lf_dropShadowPanGestureRecognizer;

@end

NS_ASSUME_NONNULL_END
