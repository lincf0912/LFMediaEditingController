//
//  LFFilter+Initialize.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface LFFilter ()

/**
 Creates and returns an empty LFFilter that has no CIFilter attached to it.
 It won't do anything when processing an image unless you add a non empty sub filter to it.
 */
+ (instancetype)emptyFilter;

/**
 Creates and returns an LFFilter that will have the given CIFilter attached.
 */
+ (instancetype)filterWithCIFilter:(CIFilter *__nullable)CIFilter;

/**
 Creates and returns an LFFilter attached to a newly created CIFilter from the given CIFilter name.
 */
+ (instancetype __nullable)filterWithCIFilterName:(NSString *__nonnull)name;

/**
 Creates and returns an LFFilter that will process the images using the given affine transform.
 */
+ (instancetype)filterWithAffineTransform:(CGAffineTransform)affineTransform;

/**
 Creates and returns a filter with a serialized filter data.
 */
+ (instancetype __nullable)filterWithData:(NSData *__nonnull)data;

/**
 Creates and returns a filter with a serialized filter data.
 */
+ (instancetype __nullable)filterWithData:(NSData *__nonnull)data error:(NSError *__nullable*__nullable)error;

/**
 Creates and returns a filter with an URL containing a serialized filter data.
 */
+ (instancetype)filterWithContentsOfURL:(NSURL *__nonnull)url;

/**
 Creates and returns a filter that will apply a CIImage on top
 */
+ (instancetype)filterWithCIImage:(CIImage *)image;

/**
 Creates and returns a filter with a block using a custom way to changed CIImage
 */
+ (instancetype)filterWithBlock:(LFFilterHandle)block;


@end

NS_ASSUME_NONNULL_END
