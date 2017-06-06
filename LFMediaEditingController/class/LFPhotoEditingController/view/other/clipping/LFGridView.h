//
//  LFGridView.h
//  ClippingText
//
//  Created by LamTsanFeng on 2017/3/7.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LFGridViewDelegate;
@interface LFGridView : UIView

@property (nonatomic, assign) CGRect gridRect;
- (void)setGridRect:(CGRect)gridRect animated:(BOOL)animated;
- (void)setGridRect:(CGRect)gridRect maskLayer:(BOOL)isMaskLayer animated:(BOOL)animated;
/** 最小尺寸 CGSizeMake(80, 80); */
@property (nonatomic, assign) CGSize controlMinSize;
/** 最大尺寸 CGRectInset(self.bounds, 50, 50) */
@property (nonatomic, assign) CGRect controlMaxRect;

/** 显示遮罩层（触发拖动条件必须设置为YES） */
@property (nonatomic, assign) BOOL showMaskLayer;

@property (nonatomic, weak) id<LFGridViewDelegate> delegate;

@end

@protocol LFGridViewDelegate <NSObject>

- (void)lf_gridViewDidBeginResizing:(LFGridView *)gridView;
- (void)lf_gridViewDidResizing:(LFGridView *)gridView;
- (void)lf_gridViewDidEndResizing:(LFGridView *)gridView;

@end
