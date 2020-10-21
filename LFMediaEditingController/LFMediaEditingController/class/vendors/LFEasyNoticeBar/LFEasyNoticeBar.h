//
//  LFEasyNoticeBar.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/9.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LFEasyNoticeBarDisplayType) {
    LFEasyNoticeBarDisplayTypeInfo,
    LFEasyNoticeBarDisplayTypeSuccess,
    LFEasyNoticeBarDisplayTypeWarning,
    LFEasyNoticeBarDisplayTypeError
};

@interface LFEasyNoticeBarConfig : NSObject
/**
 *   Notice title, default is nil.
 */
@property (nonatomic, copy) NSString *title;

/**
 *   NoticeBar display type, default is LFEasyNoticeBarDisplayTypeInfo.
 */
@property (nonatomic, assign) LFEasyNoticeBarDisplayType type;

/**
 *   Margin around the noticeBar, default is 20.0f.
 */
@property (nonatomic, assign) CGFloat margin;

/**
 *   Notice title color, default is black.
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 *   Background color, default is white.
 */
@property (nonatomic, strong) UIColor *backgroundColor;

/**
 *   UIStatusBarStyle, default is UIStatusBarStyleDefault.
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@end

@interface LFEasyNoticeBar : UIView

@property (nonatomic, readonly) LFEasyNoticeBarConfig *config;

- (void)showWithDuration:(NSTimeInterval)duration;

+ (void)showAnimationWithConfig:(LFEasyNoticeBarConfig *)config;
+ (void)hideAll;

@end

NS_ASSUME_NONNULL_END
