//
//  LFFilterImageView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilterImageView.h"

@implementation LFFilterImageView

- (CIImage *)renderedCIImageInRect:(CGRect)rect {
    CIImage *image = [super renderedCIImageInRect:rect];
    
    if (image != nil) {
        if (_filter != nil) {
            image = [_filter imageByProcessingImage:image atTime:self.CIImageTime];
        }
    }
    
    return image;
}

- (void)setFilter:(LFFilter *)filter {
    _filter = filter;
    
    [self setNeedsDisplay];
}

@end
