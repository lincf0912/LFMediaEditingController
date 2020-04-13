//
//  NSObject+LFTipsGuideView.m
//  LFTipsGuideView
//
//  Created by TsanFeng Lam on 2020/2/4.
//  Copyright © 2020 lincf0912. All rights reserved.
//

#import "NSObject+LFTipsGuideView.h"
#import "LFTipsGuideView.h"
#import "LFTipsGuideManager.h"

@implementation NSObject (LFTipsGuideView)

- (void)lf_showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr
{
    [self lf_showInView:view maskViews:views withTips:tipsArr times:1];
}
- (void)lf_showInView:(UIView *)view maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times
{
    if ([self.class isKindOfClass:[LFTipsGuideManager class]]) {
        return;
    }
    [[LFTipsGuideManager manager] writeClass:self.class maskViews:views withTips:tipsArr times:times];
    if ([[LFTipsGuideManager manager] isValidWithClass:self.class maskViews:views withTips:tipsArr]) {
        LFTipsGuideView *guide = [LFTipsGuideView new];
        [guide showInView:view maskViews:views withTips:tipsArr];
    }
}
- (void)lf_showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr
{
    [self lf_showInView:view maskRects:rects withTips:tipsArr times:1];
}
- (void)lf_showInView:(UIView *)view maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times
{
    if ([self.class isKindOfClass:[LFTipsGuideManager class]]) {
        return;
    }
    [[LFTipsGuideManager manager] writeClass:self.class maskRects:rects withTips:tipsArr times:times];
    if ([[LFTipsGuideManager manager] isValidWithClass:self.class maskRects:rects withTips:tipsArr]) {
        LFTipsGuideView *guide = [LFTipsGuideView new];
        [guide showInView:view maskRects:rects withTips:tipsArr];
    }
}

@end
