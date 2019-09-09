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

struct LFEasyNoticeBarConfig {
    /**
     *   Notice title, default is nil.
     */
    NSString *title;

    /**
     *   NoticeBar display type, default is LFEasyNoticeBarDisplayTypeInfo.
     */
    LFEasyNoticeBarDisplayType type;

    /**
     *   Margin around the noticeBar, default is 20.0f.
     */
    CGFloat margin;

    /**
     *   Notice title color, default is black.
     */
    UIColor *textColor;

    /**
     *   Background color, default is white.
     */
    UIColor *backgroundColor;
    
    /**
     *   UIStatusBarStyle, default is UIStatusBarStyleDefault.
     */
    UIStatusBarStyle statusBarStyle;
};
typedef struct LFEasyNoticeBarConfig LFEasyNoticeBarConfig;

UIKIT_EXTERN LFEasyNoticeBarConfig LFEasyNoticeBarConfigDefault(void);

@interface LFEasyNoticeBar : UIView

@property (nonatomic, readonly) LFEasyNoticeBarConfig config;

- (void)showWithDuration:(NSTimeInterval)duration;

+ (void)showAnimationWithConfig:(LFEasyNoticeBarConfig)config;
+ (void)hideAll;

@end

NS_ASSUME_NONNULL_END
