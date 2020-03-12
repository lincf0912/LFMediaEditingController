/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>

/**
 You can use switch case like normal enum. It's also recommended to add a default case. You should not assume anything about the raw value.
 For custom coder plugin, it can also extern the enum for supported format. See `SDImageCoder` for more detailed information.
 */
typedef NSInteger JRImageFormat NS_TYPED_EXTENSIBLE_ENUM;
static const JRImageFormat JRImageFormatUndefined = -1;
static const JRImageFormat JRImageFormatJPEG      = 0;
static const JRImageFormat JRImageFormatPNG       = 1;
static const JRImageFormat JRImageFormatGIF       = 2;
static const JRImageFormat JRImageFormatTIFF      = 3;
static const JRImageFormat JRImageFormatWebP      = 4;
static const JRImageFormat JRImageFormatHEIC      = 5;
static const JRImageFormat JRImageFormatHEIF      = 6;

/**
 NSData category about the image content type and UTI.
 */
@interface NSData (JRImageContentType)

/**
 *  Return image format
 *
 *  @param data the input image dataJR
 *
 *  @return the image format as `SDImageFormat` (enum)
 */
+ (JRImageFormat)jr_imageFormatForImageData:(nullable NSData *)data;

/**
 *  Convert SDImageFormat to UTType
 *
 *  @param format Format as SDImageFormat
 *  @return The UTType as CFStringRef
 */
+ (nonnull CFStringRef)jr_UTTypeFromImageFormat:(JRImageFormat)format CF_RETURNS_NOT_RETAINED NS_SWIFT_NAME(sd_UTType(from:));

/**
 *  Convert UTTyppe to SDImageFormat
 *
 *  @param uttype The UTType as CFStringRef
 *  @return The Format as SDImageFormat
 */
+ (JRImageFormat)jr_imageFormatFromUTType:(nonnull CFStringRef)uttype;

@end
