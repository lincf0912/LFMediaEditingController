//
//  LFGridLayer.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/3/6.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LFGridLayer : CAShapeLayer

/** 圆形 */
@property (nonatomic, assign, getter=isCircle) BOOL circle;

@property (nonatomic, assign) CGRect gridRect;
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated;
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

//@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;

@end
