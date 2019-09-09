//
//  LFChalkBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/6.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFChalkBrush.h"
#import "NSBundle+LFMediaEditing.h"
#import "LFBrushCache.h"

NSString *const LFChalkBrushName = @"Chalk";

@interface LFChalkBrush ()

@end

@implementation LFChalkBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setLineColor:(UIColor *)lineColor
{
    UIImage *image =  [[LFBrushCache share] objectForKey:LFChalkBrushName];
    if (image == nil) {
        image = [NSBundle LFME_brushImageNamed:LFChalkBrushName];
        [[LFBrushCache share] setObject:image forKey:LFChalkBrushName];
    }
    
    @autoreleasepool {
        //redraw image using device context
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
        [lineColor setFill];
        CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        UIRectFill(bounds);
        //Draw the tinted image in context
        [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    [super setLineColor:[UIColor colorWithPatternImage:image]];
}

@end
