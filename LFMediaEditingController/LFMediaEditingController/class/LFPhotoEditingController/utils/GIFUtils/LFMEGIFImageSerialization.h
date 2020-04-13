//
//  LFMEGIFImageSerialization.h
//  LFImagePickerController
//
//  Created by LamTsanFeng on 2017/5/17.
//  Copyright © 2017年 LamTsanFeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImageGIFRepresentation(UIImage * image);

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImageGIFRepresentation(UIImage * image, NSTimeInterval duration, NSUInteger loopCount, NSError * _Nullable __autoreleasing * _Nullable error);

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImageGIFRepresentation(UIImage * image, NSArray<NSNumber *> * durations, NSUInteger loopCount, NSError * _Nullable __autoreleasing * _Nullable error);

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImagePNGRepresentation(UIImage * image);

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImageJPEGRepresentation(UIImage * image);

extern __attribute__((overloadable)) NSData * _Nullable LFME_UIImageRepresentation(UIImage * image, CFStringRef __nonnull type, NSError * _Nullable __autoreleasing * _Nullable error);


extern __attribute__((overloadable)) NSArray<NSNumber *> * _Nullable LFME_UIImageGIFDurationsFromData(NSData *data, NSError * _Nullable __autoreleasing * _Nullable error);

NS_ASSUME_NONNULL_END
