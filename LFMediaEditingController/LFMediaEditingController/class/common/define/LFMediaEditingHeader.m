//
//  LFMediaEditingHeader.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/7/31.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFMediaEditingHeader.h"

double const LFMediaEditMinRate = 0.5f;
double const LFMediaEditMaxRate = 2.f;

CGRect LFMediaEditProundRect(CGRect rect)
{
    rect.origin.x = ((int)(rect.origin.x+0.5)*1.f);
    rect.origin.y = ((int)(rect.origin.y+0.5)*1.f);
    rect.size.width = ((int)(rect.size.width+0.5)*1.f);
    rect.size.height = ((int)(rect.size.height+0.5)*1.f);
    return rect;
}
