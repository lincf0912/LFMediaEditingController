//
//  FilterSuiteUtils.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/6.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LFFilterNameType) {
    LFFilterNameType_None = 0,
    LFFilterNameType_LinearCurve,
    LFFilterNameType_Chrome,
    LFFilterNameType_Fade,
    LFFilterNameType_Instant,
    LFFilterNameType_Mono,
    LFFilterNameType_Noir,
    LFFilterNameType_Process,
    LFFilterNameType_Tonal,
    LFFilterNameType_Transfer,
    LFFilterNameType_CurveLinear,
    LFFilterNameType_Invert,
    LFFilterNameType_Monochrome,
};

OBJC_EXTERN NSString *lf_descWithType(LFFilterNameType type);

OBJC_EXTERN NSString *lf_filterNameWithType(LFFilterNameType type);

OBJC_EXTERN UIImage *lf_filterImageWithType(UIImage *image, LFFilterNameType type);
