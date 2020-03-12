/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSData+JRImageContentType.h"
#import <MobileCoreServices/MobileCoreServices.h>

// AVFileTypeHEIC/AVFileTypeHEIF is defined in AVFoundation via iOS 11, we use this without import AVFoundation
#define kJRUTTypeHEIC ((__bridge CFStringRef)@"public.heic")
#define kJRUTTypeHEIF ((__bridge CFStringRef)@"public.heif")
// HEIC Sequence (Animated Image)
#define kJRUTTypeHEICS ((__bridge CFStringRef)@"public.heics")
// Currently Image/IO does not support WebP
#define kJRUTTypeWebP ((__bridge CFStringRef)@"public.webp")

@implementation NSData (JRImageContentType)

+ (JRImageFormat)jr_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return JRImageFormatUndefined;
    }
    
    // File signatures table: http://www.garykessler.net/library/file_sigs.html
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return JRImageFormatJPEG;
        case 0x89:
            return JRImageFormatPNG;
        case 0x47:
            return JRImageFormatGIF;
        case 0x49:
        case 0x4D:
            return JRImageFormatTIFF;
        case 0x52: {
            if (data.length >= 12) {
                //RIFF....WEBP
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
                if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                    return JRImageFormatWebP;
                }
            }
            break;
        }
        case 0x00: {
            if (data.length >= 12) {
                //....ftypheic ....ftypheix ....ftyphevc ....ftyphevx
                NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(4, 8)] encoding:NSASCIIStringEncoding];
                if ([testString isEqualToString:@"ftypheic"]
                    || [testString isEqualToString:@"ftypheix"]
                    || [testString isEqualToString:@"ftyphevc"]
                    || [testString isEqualToString:@"ftyphevx"]) {
                    return JRImageFormatHEIC;
                }
                //....ftypmif1 ....ftypmsf1
                if ([testString isEqualToString:@"ftypmif1"] || [testString isEqualToString:@"ftypmsf1"]) {
                    return JRImageFormatHEIF;
                }
            }
            break;
        }
    }
    return JRImageFormatUndefined;
}

+ (nonnull CFStringRef)jr_UTTypeFromImageFormat:(JRImageFormat)format {
    CFStringRef UTType;
    switch (format) {
        case JRImageFormatJPEG:
            UTType = kUTTypeJPEG;
            break;
        case JRImageFormatPNG:
            UTType = kUTTypePNG;
            break;
        case JRImageFormatGIF:
            UTType = kUTTypeGIF;
            break;
        case JRImageFormatTIFF:
            UTType = kUTTypeTIFF;
            break;
        case JRImageFormatWebP:
            UTType = kJRUTTypeWebP;
            break;
        case JRImageFormatHEIC:
            UTType = kJRUTTypeHEIC;
            break;
        case JRImageFormatHEIF:
            UTType = kJRUTTypeHEIF;
            break;
        default:
            // default is kUTTypePNG
            UTType = kUTTypePNG;
            break;
    }
    return UTType;
}

+ (JRImageFormat)jr_imageFormatFromUTType:(CFStringRef)uttype {
    if (!uttype) {
        return JRImageFormatUndefined;
    }
    JRImageFormat imageFormat;
    if (CFStringCompare(uttype, kUTTypeJPEG, 0) == kCFCompareEqualTo) {
        imageFormat = JRImageFormatJPEG;
    } else if (CFStringCompare(uttype, kUTTypePNG, 0) == kCFCompareEqualTo) {
        imageFormat = JRImageFormatPNG;
    } else if (CFStringCompare(uttype, kUTTypeGIF, 0) == kCFCompareEqualTo) {
        imageFormat = JRImageFormatGIF;
    } else if (CFStringCompare(uttype, kUTTypeTIFF, 0) == kCFCompareEqualTo) {
        imageFormat = JRImageFormatTIFF;
    } else if (CFStringCompare(uttype, kJRUTTypeWebP, 0) == kCFCompareEqualTo) {
        imageFormat = JRImageFormatWebP;
    } else if (CFStringCompare(uttype, kJRUTTypeHEIC, 0) == kCFCompareEqualTo) {
        imageFormat = JRImageFormatHEIC;
    } else if (CFStringCompare(uttype, kJRUTTypeHEIF, 0) == kCFCompareEqualTo) {
        imageFormat = JRImageFormatHEIF;
    } else {
        imageFormat = JRImageFormatUndefined;
    }
    return imageFormat;
}

@end
