//
//  FilterSuiteUtils.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/6.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "FilterSuiteUtils.h"
#import "LFFilterSuiteHeader.h"

NSString *lf_descWithType(LFFilterNameType type)
{
    NSString *desc = @"Original";
    switch (type) {
        case LFFilterNameType_None:
            break;
        case LFFilterNameType_LinearCurve:
            desc = @"Curve";
            break;
        case LFFilterNameType_Chrome:
            desc = @"Chrome";
            break;
        case LFFilterNameType_Fade:
            desc = @"Fade";
            break;
        case LFFilterNameType_Instant:
            desc = @"Instant";
            break;
        case LFFilterNameType_Mono:
            desc = @"Mono";
            break;
        case LFFilterNameType_Noir:
            desc = @"Noir";
            break;
        case LFFilterNameType_Process:
            desc = @"Process";
            break;
        case LFFilterNameType_Tonal:
            desc = @"Tonal";
            break;
        case LFFilterNameType_Transfer:
            desc = @"Transfer";
            break;
        case LFFilterNameType_CurveLinear:
            desc = @"Linear";
            break;
        case LFFilterNameType_Invert:
            desc = @"Invert";
            break;
        case LFFilterNameType_Monochrome:
            desc = @"Monochrome";
            break;
    }
    return desc;
}

NSString *lf_filterNameWithType(LFFilterNameType type)
{
    NSString *filterName = nil;
    switch (type) {
        case LFFilterNameType_None:
            break;
        case LFFilterNameType_LinearCurve:
            filterName = @"CILinearToSRGBToneCurve";
            break;
        case LFFilterNameType_Chrome:
            filterName = @"CIPhotoEffectChrome";
            break;
        case LFFilterNameType_Fade:
            filterName = @"CIPhotoEffectFade";
            break;
        case LFFilterNameType_Instant:
            filterName = @"CIPhotoEffectInstant";
            break;
        case LFFilterNameType_Mono:
            filterName = @"CIPhotoEffectMono";
            break;
        case LFFilterNameType_Noir:
            filterName = @"CIPhotoEffectNoir";
            break;
        case LFFilterNameType_Process:
            filterName = @"CIPhotoEffectProcess";
            break;
        case LFFilterNameType_Tonal:
            filterName = @"CIPhotoEffectTonal";
            break;
        case LFFilterNameType_Transfer:
            filterName = @"CIPhotoEffectTransfer";
            break;
        case LFFilterNameType_CurveLinear:
            filterName = @"CISRGBToneCurveToLinear";
            break;
        case LFFilterNameType_Invert:
            filterName = @"CIColorInvert";
            break;
        case LFFilterNameType_Monochrome:
            filterName = @"CIColorMonochrome";
            break;
    }
    return filterName;
}

LFFilter *lf_filterWithType(LFFilterNameType type)
{
    LFFilter *filter = nil;
    NSString *name = lf_filterNameWithType(type);
    if ([name containsString:@"|"]) {
        //组合滤镜
        LFMutableFilter *mutableFilter = nil;
        for (NSString *subName in [name componentsSeparatedByString:@"|"]) {
            if (mutableFilter == nil) {
                mutableFilter = [LFMutableFilter filterWithCIFilterName:subName];
            } else {
                [mutableFilter addSubFilter:[LFFilter filterWithCIFilterName:subName]];
            }
        }
        filter = mutableFilter;
    } else {
        filter = [LFFilter filterWithCIFilterName:name];
    }
    return filter;
}

UIImage *lf_filterImageWithType(UIImage *image, LFFilterNameType type)
{
    LFFilter *filter = lf_filterWithType(type);
    if (filter) {
        return [filter UIImageByProcessingUIImage:image];
    } else {
        return image;
    }
}
