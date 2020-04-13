//
//  LFSafeAreaMaskView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/14.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFSafeAreaMaskView.h"
#import "LFGridMaskLayer.h"

@interface LFSafeAreaMaskView ()

@property (nonatomic, weak) LFGridMaskLayer *gridMaskLayer;

@end

@implementation LFSafeAreaMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    /** 遮罩 */
    LFGridMaskLayer *gridMaskLayer = [[LFGridMaskLayer alloc] init];
    gridMaskLayer.frame = self.bounds;
    gridMaskLayer.maskColor = [UIColor colorWithWhite:.0f alpha:.5f].CGColor;
    [self.layer addSublayer:gridMaskLayer];
    self.gridMaskLayer = gridMaskLayer;
}

- (void)setMaskRect:(CGRect)maskRect
{
    _maskRect = maskRect;
    if (self.showMaskLayer) {
        [self.gridMaskLayer setMaskRect:maskRect animated:YES];
    }
}

- (void)setShowMaskLayer:(BOOL)showMaskLayer
{
    if (_showMaskLayer != showMaskLayer) {
        _showMaskLayer = showMaskLayer;
        if (showMaskLayer) {
            /** 还原遮罩 */
            [self.gridMaskLayer setMaskRect:self.maskRect animated:YES];
        } else {
            /** 扩大遮罩范围 */
            [self.gridMaskLayer clearMaskWithAnimated:YES];
        }
    }
}

@end
