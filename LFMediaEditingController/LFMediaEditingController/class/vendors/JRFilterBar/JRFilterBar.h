//
//  JRStrainImageShowView.h
//  JRCollectionView
//
//  Created by Mr.D on 2018/8/2.
//  Copyright © 2018年 Mr.D. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const JR_FilterBar_MAX_WIDTH;

@protocol JRFilterBarDelegate, JRFilterBarDataSource;

@interface JRFilterBar : UIView
/** 默认选择图片类型 */
@property (nonatomic, readonly) NSInteger defalutEffectType;
/** 默认字体和框框颜色 */
@property (nonatomic, strong) UIColor *defaultColor;
/** 已选字体和框框颜色 */
@property (nonatomic, strong) UIColor *selectColor;

@property (nonatomic, weak) id<JRFilterBarDelegate> delegate;

@property (nonatomic, weak) id<JRFilterBarDataSource>dataSource;

- (instancetype)initWithFrame:(CGRect)frame defalutEffectType:(NSInteger)defalutEffectType dataSource:(NSArray<NSNumber *> *)dataSource;

@end

@protocol JRFilterBarDelegate <NSObject>

- (void)jr_filterBar:(JRFilterBar *)jr_filterBar didSelectImage:(UIImage *)image effectType:(NSInteger)effectType;

@end

@protocol JRFilterBarDataSource <NSObject>

- (UIImage *)jr_async_filterBarImageForEffectType:(NSInteger)type;

- (NSString *)jr_filterBarNameForEffectType:(NSInteger)type;

@end
