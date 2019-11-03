//
//  SPDropMenu.h
//  DropDownMenu
//
//  Created by TsanFeng Lam on 2019/8/29.
//  Copyright © 2019 SampleProjectsBooth. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPDropMainMenuHeader.h"
#import "SPDropItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPDropMenu : NSObject

#pragma mark - preporty
/** 自动收起 */
+ (void)setAutoDismiss:(BOOL)isAutoDismiss;
/** 是否显示 */
+ (BOOL)isOnShow;
/** 背景颜色 */
+ (void)setBackgroundColor:(UIColor *)color;
/** 显示方向 */
+ (void)setDirection:(SPDropMainMenuDirection)direction;

#pragma mark - function
+ (void)showInView:(UIView *)view items:(NSArray <id <SPDropItemProtocol>>*)items;
+ (void)showFromPoint:(CGPoint)point items:(NSArray <id <SPDropItemProtocol>>*)items;

+ (void)dismiss;


@end

NS_ASSUME_NONNULL_END
