//
//  UIViewController+LFPresentation.m
//  HelloOC
//
//  Created by TsanFeng Lam on 2019/10/14.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "UIViewController+LFPresentation.h"
#import <objc/runtime.h>

@interface LFPresentationDropShadowViewProperty : NSObject

@property (nonatomic, weak) UIPanGestureRecognizer *lf_dropShadowPanGestureRecognizer;

@end

@implementation LFPresentationDropShadowViewProperty

@end

static const char * LFPresentationDropItemListKey = "LFPresentationDropItemListKey";

@implementation UIViewController (LFPresentation)

- (UIPanGestureRecognizer *)lf_dropShadowPanGestureRecognizer
{
    NSMapTable *dropShadowPropertys = [UIViewController lf_presentationDropList];
    
    UIPanGestureRecognizer *pan = nil;
    for (UIView *view in dropShadowPropertys) {
        if ([self.view isDescendantOfView:view]) {
            LFPresentationDropShadowViewProperty *item = [dropShadowPropertys objectForKey:view];
            pan = item.lf_dropShadowPanGestureRecognizer;
            break;
        }
    }
    
    return pan;
}

#pragma mark - previate
+ (NSMapTable *)lf_presentationDropList{
    NSMapTable *list = objc_getAssociatedObject(self, LFPresentationDropItemListKey);
    if (list == nil) {
        list = [NSMapTable weakToStrongObjectsMapTable];
        objc_setAssociatedObject(self, LFPresentationDropItemListKey, list, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return list;
}

@end

@interface UIView (LFPresentation)

@end

@implementation UIView (LFPresentation)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL originalSelector = @selector(addGestureRecognizer:);
        SEL swizzledSelector = NSSelectorFromString([NSString stringWithFormat:@"lf_presentation_track_%@", NSStringFromSelector(originalSelector)]);
        [self LFPresentation_swizzledSelector:originalSelector swizzledSelector:swizzledSelector];
    });
}

+ (void)LFPresentation_swizzledSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    // When swizzling a class method, use the following:
    // Class class = object_getClass((id)self);
//    SEL originalSelector = @selector(gestureRecognizer:shouldReceiveTouch:);
//    SEL swizzledSelector = @selector(track_gestureRecognizer:shouldReceiveTouch:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)lf_presentation_track_addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
{
    [self lf_presentation_track_addGestureRecognizer:gestureRecognizer];
    NSArray *privateStrArr = @[@"View", @"Shadow", @"Drop", @"I", @"U"];
    NSString *className =  [[[privateStrArr reverseObjectEnumerator] allObjects] componentsJoinedByString:@""];
    if ([self isKindOfClass:NSClassFromString(className)]) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            LFPresentationDropShadowViewProperty *item = [LFPresentationDropShadowViewProperty new];
            item.lf_dropShadowPanGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
            [[UIViewController lf_presentationDropList] setObject:item forKey:self];
        }
    }
}

@end
