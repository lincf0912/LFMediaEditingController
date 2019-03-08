//
//  LFVideoEdit.m
//  LFMediaEditingController
//
//  Created by LamTsanFeng on 2017/7/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import "LFVideoEdit.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+LFMECommon.h"
#import "AVAsset+LFMECommon.h"

@implementation LFVideoEdit

- (instancetype)initWithEditAsset:(AVAsset *)editAsset editFinalURL:(NSURL *)editFinalURL data:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        _editAsset = editAsset;
        _editFinalURL = editFinalURL;
        _editData = data;
        [self createfirstImage];
    }
    return self;
}

- (void)createfirstImage
{
    AVAsset *asset = nil;
    if (self.editFinalURL) {
        asset = [[AVURLAsset alloc] initWithURL:self.editFinalURL options:nil];
    } else {
        asset = self.editAsset;
    }
    
    _duration = CMTimeGetSeconds(asset.duration);
    
    _editPreviewImage = [asset lf_firstImage:nil];
    CGFloat width = 80.f * 2.f;
    CGSize size = [UIImage LFME_scaleImageSizeBySize:_editPreviewImage.size targetSize:CGSizeMake(width, width) isBoth:NO];
    _editPosterImage = [_editPreviewImage LFME_scaleToSize:size];
    
}
@end
