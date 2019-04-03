//
//  LFMEGIFImageSerialization.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/5/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImageGIFRepresentation(UIImage * _Nullable image);

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImageGIFRepresentation(UIImage * _Nullable image, NSTimeInterval duration, NSUInteger loopCount, NSError * _Nullable __autoreleasing * _Nullable error);

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImagePNGRepresentation(UIImage * _Nullable image);

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImageJPEGRepresentation(UIImage * _Nullable image);

extern __attribute__((overloadable)) NSData * _Nonnull LFME_UIImageRepresentation(UIImage * _Nullable image, CFStringRef __nonnull type, NSError * _Nullable __autoreleasing *  _Nullable error);
