//
//  LFFilter.h
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

typedef CIImage *_Nullable(^LFFilterHandle)(CIImage *image);

@interface LFFilter : NSObject <NSCoding, NSCopying>

/**
 The underlying CIFilter attached to this LFFilter instance.
 */
@property (readonly, nonatomic) CIFilter *__nullable CIFilter;

/**
 The name of this filter. By default it takes the name of the attached
 CIFilter.
 */
@property (strong, nonatomic) NSString *__nullable name;

/**
 Whether this filter should process the images from imageByProcessingImage:.
 */
@property (assign, nonatomic) BOOL enabled;

/**
 Whether this LFFilter and all its subfilters have no CIFilter attached.
 If YES, it means that calling imageByProcessingImage: will always return the input
 image without any modification.
 */
@property (readonly, nonatomic) BOOL isEmpty;

/**
 Initialize a LFFilter with an attached CIFilter.
 CIFilter can be nil.
 */
- (nullable instancetype)initWithCIFilter:(CIFilter *__nullable)filter;

/**
 Reset the attached CIFilter parameter values to default for this instance
 and all the sub filters.
 */
- (void)resetToDefaults;

/**
 Returns the CIImage by processing the given CIImage.
 */
- (CIImage *__nullable)imageByProcessingImage:(CIImage *__nullable)image;

/**
 Returns the CIImage by processing the given CIImage with the given time.
 */
- (CIImage *__nullable)imageByProcessingImage:(CIImage *__nullable)image atTime:(CFTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
