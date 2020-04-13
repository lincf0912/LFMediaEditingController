//
//  NSData+CompressDecodedImage.m
//  StickerBooth
//
//  Created by TsanFeng Lam on 2020/3/10.
//  Copyright © 2020 lfsampleprojects. All rights reserved.
//

#import "NSData+CompressDecodedImage.h"
#import "LFImageCoder.h"

inline static UIImageOrientation CompressDecodedImage_UIImageOrientationFromEXIFValue(NSInteger value) {
    switch (value) {
        case kCGImagePropertyOrientationUp: return UIImageOrientationUp;
        case kCGImagePropertyOrientationDown: return UIImageOrientationDown;
        case kCGImagePropertyOrientationLeft: return UIImageOrientationLeft;
        case kCGImagePropertyOrientationRight: return UIImageOrientationRight;
        case kCGImagePropertyOrientationUpMirrored: return UIImageOrientationUpMirrored;
        case kCGImagePropertyOrientationDownMirrored: return UIImageOrientationDownMirrored;
        case kCGImagePropertyOrientationLeftMirrored: return UIImageOrientationLeftMirrored;
        case kCGImagePropertyOrientationRightMirrored: return UIImageOrientationRightMirrored;
        default: return UIImageOrientationUp;
    }
}

@implementation NSData (CompressDecodedImage)

- (UIImage * __nullable)dataDecodedImageWithSize:(CGSize)size mode:(UIViewContentMode)mode
{
    CGImageSourceRef _imgSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)(self), NULL);
    if (_imgSourceRef) {
        NSUInteger count = CGImageSourceGetCount(_imgSourceRef);
        if (count > 0) {
            UIImageOrientation imgOrientation = UIImageOrientationUp;
            //exifInfo 包含了很多信息,有兴趣的可以打印看看,我们只需要Orientation这个字段
            CFDictionaryRef exifInfo = CGImageSourceCopyPropertiesAtIndex(_imgSourceRef, 0,NULL);
            if (exifInfo) {
                //判断Orientation这个字段,如果图片经过PS等处理,exif信息可能会丢失
                if(CFDictionaryContainsKey(exifInfo, kCGImagePropertyOrientation)){
                    CFNumberRef orientation = CFDictionaryGetValue(exifInfo, kCGImagePropertyOrientation);
                    NSInteger orientationValue = 0;
                    CFNumberGetValue(orientation, kCFNumberIntType, &orientationValue);
                    imgOrientation = CompressDecodedImage_UIImageOrientationFromEXIFValue(orientationValue);
                }
                CFRelease(exifInfo);
            }
            CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_imgSourceRef, 0, NULL);
            CGImageRef decodeImageRef = LFIC_CGImageScaleDecodedFromCopy(imageRef, size, mode, imgOrientation);
            if (imageRef) {
                CGImageRelease(imageRef);
            }
            CFRelease(_imgSourceRef);
            
            if (decodeImageRef) {
                UIImage *image = [UIImage imageWithCGImage:decodeImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                CGImageRelease(decodeImageRef);
                return image;
            }
        }
    }
    return nil;
}

@end
