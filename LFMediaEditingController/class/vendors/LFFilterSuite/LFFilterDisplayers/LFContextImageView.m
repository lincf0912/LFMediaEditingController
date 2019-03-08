//
//  LFImageView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFContextImageView.h"
#import "LFSampleBufferHolder.h"

@interface LFContextImageView () <GLKViewDelegate>

@property (nonatomic, strong) GLKView *GLKView;

@property (nonatomic, strong) LFSampleBufferHolder *sampleBufferHolder;

@end

@implementation LFContextImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self _imageViewCommonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self _imageViewCommonInit];
    }
    
    return self;
}

- (void)_imageViewCommonInit {
    _scaleAndResizeCIImageAutomatically = YES;
    self.preferredCIImageTransform = CGAffineTransformIdentity;
}

- (BOOL)loadContextIfNeeded {
    if (_context == nil) {
        LFContextType contextType = _contextType;
        if (contextType == LFContextTypeAuto) {
            
            contextType = [LFContext suggestedContextType];
        }
        
        NSDictionary *options = nil;
        switch (contextType) {
            case LFContextTypeCoreGraphics: {
                CGContextRef contextRef = UIGraphicsGetCurrentContext();
                
                if (contextRef == nil) {
                    return NO;
                }
                options = @{LFContextOptionsCGContextKey: (__bridge id)contextRef};
            }
                break;
            default:
                break;
        }
        
        self.context = [LFContext contextWithType:contextType options:options];
    }
    
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _GLKView.frame = self.bounds;
}

- (void)unloadContext {
    if (_GLKView != nil) {
        [_GLKView removeFromSuperview];
        _GLKView = nil;
    }
    _context = nil;
}

- (void)setContext:(LFContext * _Nullable)context {
    [self unloadContext];
    
    if (context != nil) {
        switch (context.type) {
            case LFContextTypeCoreGraphics:
                break;
            case LFContextTypeEAGL:
                _GLKView = [[GLKView alloc] initWithFrame:self.bounds context:context.EAGLContext];
                _GLKView.contentScaleFactor = self.contentScaleFactor;
                _GLKView.delegate = self;
                [self insertSubview:_GLKView atIndex:0];
                break;
            default:
                [NSException raise:@"InvalidContext" format:@"Unsupported context type: %d. SCImageView only supports CoreGraphics, EAGL and Metal", (int)context.type];
                break;
        }
    }
    
    _context = context;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    
    [_GLKView setNeedsDisplay];
}

- (UIImage *)renderedUIImageInRect:(CGRect)rect {
    UIImage *returnedImage = nil;
    CIImage *image = [self renderedCIImageInRect:rect];
    
    if (image != nil) {
        CIContext *context = nil;
        if (![self loadContextIfNeeded]) {
            context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(NO)}];
        } else {
            context = _context.CIContext;
        }
        
        CGImageRef imageRef = [context createCGImage:image fromRect:image.extent];
        
        if (imageRef != nil) {
            returnedImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
    }
    
    return returnedImage;
}

- (CIImage *)renderedCIImageInRect:(CGRect)rect {
    CMSampleBufferRef sampleBuffer = _sampleBufferHolder.sampleBuffer;
    
    if (sampleBuffer != nil) {
        _CIImage = [CIImage imageWithCVPixelBuffer:CMSampleBufferGetImageBuffer(sampleBuffer)];
        _sampleBufferHolder.sampleBuffer = nil;
    }
    
    CIImage *image = _CIImage;
    
    if (image != nil) {
        image = [image imageByApplyingTransform:self.preferredCIImageTransform];
        
        if (self.context.type != LFContextTypeEAGL) {
            image = [image imageByApplyingOrientation:4];
        }
        
        if (self.scaleAndResizeCIImageAutomatically) {
            image = [self scaleAndResizeCIImage:image forRect:rect];
        }
    }
    
    return image;
}

- (CIImage *)renderedCIImage {
    return [self renderedCIImageInRect:self.CIImage.extent];
}

- (UIImage *)renderedUIImage {
    return [self renderedUIImageInRect:self.CIImage.extent];
}

- (CIImage *)scaleAndResizeCIImage:(CIImage *)image forRect:(CGRect)rect {
    CGSize imageSize = image.extent.size;
    
    CGFloat horizontalScale = rect.size.width / imageSize.width;
    CGFloat verticalScale = rect.size.height / imageSize.height;
    
    UIViewContentMode mode = self.contentMode;
    
    if (mode == UIViewContentModeScaleAspectFill) {
        horizontalScale = MAX(horizontalScale, verticalScale);
        verticalScale = horizontalScale;
    } else if (mode == UIViewContentModeScaleAspectFit) {
        horizontalScale = MIN(horizontalScale, verticalScale);
        verticalScale = horizontalScale;
    }
    
    return [image imageByApplyingTransform:CGAffineTransformMakeScale(horizontalScale, verticalScale)];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if ((_CIImage != nil || _sampleBufferHolder.sampleBuffer != nil) && [self loadContextIfNeeded]) {
        if (self.context.type == LFContextTypeCoreGraphics) {
            CIImage *image = [self renderedCIImageInRect:rect];
            
            if (image != nil) {
                [_context.CIContext drawImage:image inRect:rect fromRect:image.extent];
            }
        }
    }
}

- (void)setImageBySampleBuffer:(CMSampleBufferRef)sampleBuffer {
    _sampleBufferHolder.sampleBuffer = sampleBuffer;
    
    [self setNeedsDisplay];
}

+ (CGAffineTransform)preferredCIImageTransformFromUIImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) {
        return CGAffineTransformIdentity;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    return transform;
}

- (void)setImageByUIImage:(UIImage *)image {
    if (image == nil) {
        self.CIImage = nil;
    } else {
        self.preferredCIImageTransform = [LFContextImageView preferredCIImageTransformFromUIImage:image];
        self.CIImage = [CIImage imageWithCGImage:image.CGImage];
    }
}

- (void)setCIImage:(CIImage *)CIImage {
    _CIImage = CIImage;
    
    if (CIImage != nil) {
        [self loadContextIfNeeded];
    }
    
    [self setNeedsDisplay];
}

- (void)setContextType:(LFContextType)contextType {
    if (_contextType != contextType) {
        self.context = nil;
        _contextType = contextType;
    }
}

static CGRect CGRectMultiply(CGRect rect, CGFloat contentScale) {
    rect.origin.x *= contentScale;
    rect.origin.y *= contentScale;
    rect.size.width *= contentScale;
    rect.size.height *= contentScale;
    
    return rect;
}

#pragma mark -- GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    @autoreleasepool {
        rect = CGRectMultiply(rect, self.contentScaleFactor);
        glClearColor(0, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        CIImage *image = [self renderedCIImageInRect:rect];
        
        if (image != nil) {
            [_context.CIContext drawImage:image inRect:rect fromRect:image.extent];
        }
    }
}

@end
