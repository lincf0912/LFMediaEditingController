//
//  LFChalkBrush.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/6.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFChalkBrush.h"
#import "LFBrushCache.h"

NSString *const LFChalkBrushImage = @"ChalkImage";
NSString *const LFChalkBrushColor = @"ChalkColor";

@interface LFChalkBrush ()

@property (nonatomic, copy) NSString *name;

@end

@implementation LFChalkBrush

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lineWidth = 12.5;
    }
    return self;
}

- (instancetype)initWithImageName:(NSString *)name
{
    self = [self init];
    if (self) {
        _name = name;
    }
    return self;
}

- (UIColor *)lineColor
{
    LFBrushCache *imageCache = [LFBrushCache share];
    UIColor *color = [imageCache objectForKey:LFChalkBrushColor];
    
    if (color) {
        return color;
    }
    
    UIImage *image =  [imageCache objectForKey:LFChalkBrushImage];
    if (image == nil) {
        
        NSAssert(self.name!=nil, @"LFChalkBrush name is nil.");
        
        if (self.bundle) {
            /**
             framework内部加载
             */
            image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:self.name ofType:nil]];
        } else {
            /**
             framework外部加载
             */
            image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:self.name ofType:nil]];
        }
        
        [[LFBrushCache share] setObject:image forKey:LFChalkBrushImage];
    }
    
    @autoreleasepool {
        //redraw image using device context
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        [super.lineColor setFill];
        CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
        UIRectFill(bounds);
        //Draw the tinted image in context
        [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    color = [UIColor colorWithPatternImage:image];
    [imageCache setObject:color forKey:LFChalkBrushColor];
    
    return color;
}

- (void)setLineColor:(UIColor *)lineColor
{
    if (super.lineColor != lineColor) {
        [[LFBrushCache share] removeObjectForKey:LFChalkBrushColor];
        [super setLineColor:lineColor];
    }
}

@end
