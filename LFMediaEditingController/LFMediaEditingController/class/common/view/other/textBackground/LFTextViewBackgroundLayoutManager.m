//
//  LFTextViewBackgroundLayoutManager.m
//  KiraTextView
//
//  Created by LamTsanFeng on 2020/11/12.
//  Copyright © 2020 Kira. All rights reserved.
//

#import "LFTextViewBackgroundLayoutManager.h"

@interface LFTextViewBackgroundLayoutManager() {
    NSInteger maxIndex;
}

/** 当前绘制的位置集合 */
@property (nonatomic, strong) NSMutableArray <NSValue *>*rectArray;
/** 所有绘制的位置集合 */
@property (nonatomic, strong) NSMutableArray <NSValue *>*allRectArray;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, NSValue *>*allRectDict;
/** 分批绘制结束，下次需要情况集合标记 */
@property (nonatomic, assign, getter=isCleanAllRectArray) CGFloat cleanAllRectArray;

@end

@implementation LFTextViewBackgroundLayoutManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    _radius = 0.18;
}

- (NSArray<NSValue *> *)allUsedRects
{
    return self.allRectArray.copy;
}

- (NSDictionary *)layoutData
{
    NSMutableDictionary *data = @{}.mutableCopy;
    [data setObject:@(self.type) forKey:LFCGContextDrawTextBackgroundTypeName];
    [data setObject:@(self.radius) forKey:LFCGContextDrawTextBackgroundRadiusName];
    if (self.usedColor) {
        [data setObject:self.usedColor forKey:LFCGContextDrawTextBackgroundColorName];
    }
    [data setObject:self.allUsedRects forKey:LFCGContextDrawTextBackgroundLineUsedRectsName];
    [data setObject:[NSValue valueWithCGSize:self.textContainers.firstObject.size] forKey:LFCGContextDrawTextBackgroundTextContainerSizeName];
    return data.copy;
}

- (void)setLayoutData:(NSDictionary *)layoutData
{
    self.usedColor = [layoutData objectForKey:LFCGContextDrawTextBackgroundColorName];
    self.radius = [[layoutData objectForKey:LFCGContextDrawTextBackgroundRadiusName] floatValue];
    self.type = [[layoutData objectForKey:LFCGContextDrawTextBackgroundTypeName] integerValue];
}

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin {
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    
    NSRange range = [self characterRangeForGlyphRange:glyphsToShow
                                     actualGlyphRange:NULL];
    NSRange glyphRange = [self glyphRangeForCharacterRange:range
                                      actualCharacterRange:NULL];
    
//    NSLog(@"sqmTest:first : %f last : %f", firstPosition, lastPosition);
//    NSLog(@"sqmTest:rect: %f,%f, %f,%f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);

    [self.rectArray removeAllObjects];
    /** 全部绘制集合 */
    if (self.isCleanAllRectArray) {
        [self.allRectArray removeAllObjects];
        [self.allRectDict removeAllObjects];
    }
    self.cleanAllRectArray = glyphRange.location == 0;
    
    if (self.allRectArray.count == 0) {
        [self enumerateLineFragmentsForGlyphRange:NSMakeRange(0, self.numberOfGlyphs) usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
            if ([self.allRectDict objectForKey:@(usedRect.origin.y)] == nil) {
                CGRect newRect = CGRectMake(usedRect.origin.x, usedRect.origin.y, usedRect.size.width, usedRect.size.height);
                NSValue *value = [NSValue valueWithCGRect:newRect];
                [self.allRectArray addObject:value];
                [self.allRectDict setObject:value forKey:@(usedRect.origin.y)];
            }
        }];
        /** 调整超出最大时，对各个位置调整。https://www.jianshu.com/p/e72c441f14f3  */
        [self preProccess];
    }
    
    [self enumerateLineFragmentsForGlyphRange:glyphRange usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
        NSValue *value = [self.allRectDict objectForKey:@(usedRect.origin.y)];
        if (value) {
            [self.rectArray addObject:value];
        }
    }];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);   //保存当前的绘图配置信息
    CGContextTranslateCTM(context, origin.x, origin.y); //转换初始坐标系到绘制字形的位置
    
    lf_CGContextDrawTextBackground(context, self.usedColor, self.radius, self.rectArray, (LFCGContextDrawTextBackgroundType)self.type);
    
    CGContextRestoreGState(context); //恢复绘图配置信息
}

- (NSMutableArray<NSValue *> *)rectArray {
    if (!_rectArray) {
        _rectArray = @[].mutableCopy;
    }
    return _rectArray;
}

- (NSMutableArray<NSValue *> *)allRectArray {
    if (!_allRectArray) {
        _allRectArray = @[].mutableCopy;
    }
    return _allRectArray;
}

- (NSMutableDictionary<NSNumber *,NSValue *> *)allRectDict {
    if (!_allRectDict) {
        _allRectDict = @{}.mutableCopy;
    }
    return _allRectDict;
}

- (void)preProccess {
    maxIndex = 0;
    if (self.allRectArray.count < 2) {
        return;
    }
    /** 处理当前绘制位置 */
    for (int i = 1; i < self.allRectArray.count; i++) {
        maxIndex = i;
        [self processRectIndex:i];
    }
}

- (void)processRectIndex:(int) index {
    if (self.allRectArray.count < 2 || index < 1 || index > maxIndex) {
        return;
    }
    NSValue *value1 = [self.allRectArray objectAtIndex:index - 1];
    NSValue *value2 = [self.allRectArray objectAtIndex:index];
    CGRect last = value1.CGRectValue;
    CGRect cur = value2.CGRectValue;
    CGFloat R = cur.size.height * self.radius;
    
    //if t1 == true 改变cur的rect
    BOOL t1 = ((cur.origin.x - last.origin.x < 2 * R) && (cur.origin.x > last.origin.x)) || ((CGRectGetMaxX(cur) - CGRectGetMaxX(last) > -2 * R) && (CGRectGetMaxX(cur) < CGRectGetMaxX(last)));
    //if t2 == true 改变last的rect
    BOOL t2 = ((last.origin.x - cur.origin.x < 2 * R) && (last.origin.x > cur.origin.x)) || ((CGRectGetMaxX(last) - CGRectGetMaxX(cur) > -2 * R) && (CGRectGetMaxX(last) < CGRectGetMaxX(cur)));
    
    if (t2) {
        //将last的rect替换为cur的rect
        CGRect newRect = CGRectMake(cur.origin.x, last.origin.y, cur.size.width, last.size.height);
        NSValue *newValue = [NSValue valueWithCGRect:newRect];
        [self.allRectArray replaceObjectAtIndex:index - 1 withObject:newValue];
        [self.allRectDict setObject:newValue forKey:@(newRect.origin.y)];
        [self processRectIndex:index - 1];
    }
    if (t1) {
        //将cur的rect替换为last的rect
        CGRect newRect = CGRectMake(last.origin.x, cur.origin.y, last.size.width, cur.size.height);
        NSValue *newValue = [NSValue valueWithCGRect:newRect];
        [self.allRectArray replaceObjectAtIndex:index withObject:newValue];
        [self.allRectDict setObject:newValue forKey:@(newRect.origin.y)];
        [self processRectIndex:index + 1];
    }
    return;
}

@end
