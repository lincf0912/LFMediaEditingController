//
//  JRDataImageView.m
//  StickerBooth
//
//  Created by djr on 2020/3/4.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "JRDataImageView.h"
#import "LFImageCoder.h"
#import "JRConfigTool.h"
#import "JRStickerHeader.h"
#import "NSData+CompressDecodedImage.h"

@interface JRDataImageView ()


@end

@implementation JRDataImageView

@synthesize isGif = _isGif;


- (void)jr_dataForImage:(nullable NSData *)data
{
    _isGif = NO;
    if (data) {
        CGImageSourceRef _imgSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
        if (_imgSourceRef) {
            NSUInteger count = CGImageSourceGetCount(_imgSourceRef);
            if (count > 0) {
                _isGif = count > 1;
                CGSize size = self.frame.size;
                UIViewContentMode mode = self.contentMode;
                dispatch_queue_t queue = [JRConfigTool shareInstance].concurrentQueue;
                __weak typeof(self) weakSelf = self;
                dispatch_async(queue, ^{
                    if (weakSelf != nil) {
                        UIImage *image = [data dataDecodedImageWithSize:size mode:mode];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.image = image;
                        });
                    }
                });
            }
            CFRelease(_imgSourceRef);
        }
    } else {
        self.image = nil;
    }
}

- (BOOL)isGif
{
    return _isGif;
}

@end
