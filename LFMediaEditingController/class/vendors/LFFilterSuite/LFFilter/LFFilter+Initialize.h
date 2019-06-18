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
+ (LFFilter *__nonnull)emptyFilter;

/**
 Creates and returns an LFFilter that will have the given CIFilter attached.
 */
+ (LFFilter *__nonnull)filterWithCIFilter:(CIFilter *__nullable)CIFilter;

/**
 Creates and returns an LFFilter attached to a newly created CIFilter from the given CIFilter name.
 */
+ (LFFilter *__nonnull)filterWithCIFilterName:(NSString *__nonnull)name;

/**
 Creates and returns an LFFilter that will process the images using the given affine transform.
 */
+ (LFFilter *__nonnull)filterWithAffineTransform:(CGAffineTransform)affineTransform;

/**
 Creates and returns a filter with a serialized filter data.
 */
+ (LFFilter *__nonnull)filterWithData:(NSData *__nonnull)data;

/**
 Creates and returns a filter with a serialized filter data.
 */
+ (LFFilter *__nonnull)filterWithData:(NSData *__nonnull)data error:(NSError *__nullable*__nullable)error;

/**
 Creates and returns a filter with an URL containing a serialized filter data.
 */
+ (LFFilter *__nonnull)filterWithContentsOfURL:(NSURL *__nullable)url;

/**
 Creates and returns a filter that will apply a CIImage on top
 */
+ (LFFilter *__nonnull)filterWithCIImage:(CIImage *__nonnull)image;

/**
 Creates and returns a filter with a block using a custom way to changed CIImage
 */
+ (LFFilter *)filterWithBlock:(LFFilterHandle)block;


@end

NS_ASSUME_NONNULL_END
