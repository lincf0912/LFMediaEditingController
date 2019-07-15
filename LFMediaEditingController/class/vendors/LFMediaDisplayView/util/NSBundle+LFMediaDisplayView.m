//
//  NSBundle+LFMediaDisplayView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/6/20.
//  Copyright © 2019 lincf0912. All rights reserved.
//

#import "NSBundle+LFMediaDisplayView.h"

@implementation NSBundle (LFMediaDisplayView)


+ (instancetype)LFMD_imagePickerBundle
{
    static NSBundle *lfMediaEditingBundle = nil;
    if (lfMediaEditingBundle == nil) {
        lfMediaEditingBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"LFMEVideoView")] pathForResource:@"LFMediaDisplayView" ofType:@"bundle"]];
    }
    return lfMediaEditingBundle;
}

+ (UIImage *)LFMD_imageNamed:(NSString *)name inDirectory:(NSString *)subpath
{
    //  [UIImage imageNamed:[NSString stringWithFormat:@"%@/%@", kBundlePath, name]]
    NSString *extension = name.length ? (name.pathExtension.length ? name.pathExtension : @"png") : nil;
    NSString *defaultName = [name stringByDeletingPathExtension];
    NSString *bundleName = [defaultName stringByAppendingString:@"@2x"];
    //    CGFloat scale = [UIScreen mainScreen].scale;
    //    if (scale == 3) {
    //        bundleName = [name stringByAppendingString:@"@3x"];
    //    } else {
    //        bundleName = [name stringByAppendingString:@"@2x"];
    //    }
    UIImage *image = [UIImage imageWithContentsOfFile:[[self LFMD_imagePickerBundle] pathForResource:bundleName ofType:extension inDirectory:subpath]];
    if (image == nil) {
        image = [UIImage imageWithContentsOfFile:[[self LFMD_imagePickerBundle] pathForResource:defaultName ofType:extension inDirectory:subpath]];
    }
    if (image == nil) {
        image = [UIImage imageNamed:name];
    }
    return image;
}

+ (UIImage *)LFMD_imageNamed:(NSString *)name
{
    return [self LFMD_imageNamed:name inDirectory:nil];
}

@end
