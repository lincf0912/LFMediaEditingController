//
//  LFCGContextDrawTextBackground.h
//  KiraTextView
//
//  Created by LamTsanFeng on 2020/11/12.
//  Copyright © 2020 Kira. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * LFCGContextDrawTextBackgroundStringKey NS_EXTENSIBLE_STRING_ENUM;

OBJC_EXTERN LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundTypeName;
OBJC_EXTERN LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundColorName;
OBJC_EXTERN LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundRadiusName;
OBJC_EXTERN LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundLineUsedRectsName;
OBJC_EXTERN LFCGContextDrawTextBackgroundStringKey const LFCGContextDrawTextBackgroundTextContainerSizeName;

typedef NS_ENUM(NSInteger, LFCGContextDrawTextBackgroundType) {
    /** 无背景 */
    LFCGContextDrawTextBackgroundTypeNone,
    /** 边框 */
    LFCGContextDrawTextBackgroundTypeBorder,
    /** 填充 */
    LFCGContextDrawTextBackgroundTypeSolid
};

CG_EXTERN void lf_CGContextDrawTextBackground(CGContextRef cg_nullable c, UIColor  * _Nullable backgroundColor, CGFloat radius, NSArray <NSValue *>*usedRects, LFCGContextDrawTextBackgroundType type);

CG_EXTERN void lf_CGContextDrawTextBackgroundData(CGContextRef cg_nullable c, CGSize size, NSDictionary *data);

NS_ASSUME_NONNULL_END
