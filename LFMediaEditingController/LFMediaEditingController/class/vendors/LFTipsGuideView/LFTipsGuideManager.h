//
//  LFTipsGuideManager.h
//  LFTipsGuideView
//
//  Created by TsanFeng Lam on 2020/2/4.
//  Copyright © 2020 lincf0912. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFTipsGuideManager : NSObject

+ (instancetype)manager;

/// 开启提示，默认开启。
@property (nonatomic, assign, getter=isEnable) BOOL enable;

- (BOOL)isValidWithClass:(Class)aClass maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr;
- (BOOL)isValidWithClass:(Class)aClass maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr;

- (void)writeClass:(Class)aClass maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times;
- (void)writeClass:(Class)aClass maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times;

- (void)removeClass:(Class)aClass maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr;
- (void)removeClass:(Class)aClass maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr;

- (void)removeClass:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
