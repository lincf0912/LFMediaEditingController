//
//  LFImageView.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFContextImageView.h"
#import "LFSampleBufferHolder.h"
#import "LFLView.h"



#ifdef NSFoundationVersionNumber_iOS_9_0
@import MetalKit;
@interface LFContextImageView()<GLKViewDelegate, MTKViewDelegate>

@property (nonatomic, weak) MTKView *MTKView;
@property (nonatomic, strong) id<MTLCommandQueue> MTLCommandQueue;
#else
@interface LFContextImageView()<GLKViewDelegate>
#endif


@property (nonatomic, weak) GLKView *GLKView;
@property (nonatomic, weak) LFLView *LFLView;
@property (nonatomic, weak) UIView *UIView;

@property (nonatomic, strong) LFSampleBufferHolder *sampleBufferHolder;

@end

@implementation LFContextImageView

- (id)init {
    self = [super init];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    _scaleAndResizeCIImageAutomatically = YES;
    self.preferredCIImageTransform = CGAffineTransformIdentity;
    _sampleBufferHolder = [LFSampleBufferHolder new];
}

- (void)dealloc
{
    [self unloadContext];
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

- (void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    if (_GLKView) {
        [_contentView insertSubview:_GLKView atIndex:0];
    }
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect viewRect = self.bounds;
    if (self.contentView) {
        viewRect = self.contentView.bounds;
    }
    _GLKView.frame = viewRect;
    _LFLView.frame = self.bounds;
    _UIView.frame = self.bounds;

    _MTKView.frame = self.bounds;

}

- (void)unloadContext {
    if (_GLKView != nil) {
        [_GLKView removeFromSuperview];
        _GLKView.delegate = nil;
        _GLKView = nil;
    }
    if (_LFLView != nil) {
        [_LFLView removeFromSuperview];
        _LFLView = nil;
    }
    if (_UIView != nil) {
        [_UIView removeFromSuperview];
        _UIView = nil;
    }

    if (_MTKView != nil) {
        _MTLCommandQueue = nil;
        [_MTKView removeFromSuperview];
        [_MTKView releaseDrawables];
        _MTKView.delegate = nil;
        _MTKView = nil;
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
            {
                GLKView *view = [[GLKView alloc] initWithFrame:self.bounds context:context.EAGLContext];
                view.contentScaleFactor = self.contentScaleFactor;
                view.backgroundColor = [UIColor clearColor];
                view.delegate = self;
                if (self.contentView) {
                    [_contentView insertSubview:view atIndex:0];
                } else {
                    [self insertSubview:view atIndex:0];
                }
                _GLKView = view;
            }
                break;
            case LFContextTypeLargeImage:
            {
                CGFloat normalSizeScale = MIN(1, MIN(self.bounds.size.width/self.CIImage.extent.size.width,self.bounds.size.height/self.CIImage.extent.size.height));
                LFLView *view = [[LFLView alloc] initWithFrame:self.bounds];
                view.bounds = self.CIImage.extent;
                view.transform = CGAffineTransformMakeScale(normalSizeScale, normalSizeScale);
                view.contentScaleFactor = self.contentScaleFactor;
                //按照屏幕大小截取图片
                view.tileSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
                [self insertSubview:view atIndex:0];
                _LFLView = view;
            }
                break;
            case LFContextTypeDefault:
            {
                UIView *view = [[UIView alloc] initWithFrame:self.bounds];
                view.contentScaleFactor = self.contentScaleFactor;
                [self insertSubview:view atIndex:0];
                _UIView = view;
            }
                break;
#if !(TARGET_IPHONE_SIMULATOR)
#ifdef NSFoundationVersionNumber_iOS_9_0
            case LFContextTypeMetal:
            {
                _MTLCommandQueue = [context.MTLDevice newCommandQueue];
                MTKView *view = [[MTKView alloc] initWithFrame:self.bounds device:context.MTLDevice];
                view.clearColor = MTLClearColorMake(0, 0, 0, 0);
                view.contentScaleFactor = self.contentScaleFactor;
                view.delegate = self;
                view.opaque = NO;
                view.enableSetNeedsDisplay = YES;
                view.paused = YES;
                view.framebufferOnly = NO;
                [self insertSubview:view atIndex:0];
                _MTKView = view;
            }
                break;
#endif
#endif
            default:
                [NSException raise:@"InvalidContext" format:@"Unsupported context type: %d. %@ only supports CoreGraphics, EAGL and Metal", (int)context.type, NSStringFromClass(self.class)];
                break;
        }
    }
    
    _context = context;
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    
    [_GLKView setNeedsDisplay];
    if (_LFLView) {
        _LFLView.image = [self renderedUIImage];
    }
    if (_UIView) {
        CGImageRef imageRef = [self newRenderedCGImage];
        if (imageRef) {
            _UIView.layer.contents = (__bridge id _Nullable)(imageRef);
            CGImageRelease(imageRef);
        }
    }

    [_MTKView setNeedsDisplay];

}

- (UIImage *)renderedUIImageInRect:(CGRect)rect {
    
    CIImage *image = [self renderedCIImageInRect:rect];
    return [self renderedUIImageInCIImage:image];
}

- (UIImage *)renderedUIImageInCIImage:(CIImage * __nullable)image
{
    UIImage *returnedImage = nil;
    
    if (image != nil) {
        
        CGImageRef imageRef = [self newRenderedCGImageInCIImage:image];
        
        if (imageRef != nil) {
            returnedImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
        }
    }
    
    return returnedImage;
}

- (CGImageRef)newRenderedCGImageInRect:(CGRect)rect {
    
    CIImage *image = [self renderedCIImageInRect:rect];
    return [self newRenderedCGImageInCIImage:image];
}

- (CGImageRef)newRenderedCGImageInCIImage:(CIImage * __nullable)image
{
    if (image != nil) {
        CIContext *context = nil;
        if (![self loadContextIfNeeded]) {
            context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer: @(NO)}];
        } else {
            context = _context.CIContext;
        }
        
        CGImageRef imageRef = [context createCGImage:image fromRect:image.extent];
        
        return imageRef;
    }
    return NULL;
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
        
        switch (self.contextType) {
            case LFContextTypeCoreGraphics:
                if (@available(iOS 8.0, *)) {
                    image = [image imageByApplyingOrientation:4];
                }
                break;
            default:
                break;
        }
        
        if (self.scaleAndResizeCIImageAutomatically) {
            image = [self scaleAndResizeCIImage:image forRect:rect];
        }
    }
    
    return image;
}

- (CIImage *)renderedCIImage {
    CGRect extent = CGRectApplyAffineTransform(self.CIImage.extent, self.preferredCIImageTransform);
    return [self renderedCIImageInRect:extent];
}

- (UIImage *)renderedUIImage {
    CGRect extent = CGRectApplyAffineTransform(self.CIImage.extent, self.preferredCIImageTransform);
    return [self renderedUIImageInRect:extent];
}

- (CGImageRef)newRenderedCGImage {
    CGRect extent = CGRectApplyAffineTransform(self.CIImage.extent, self.preferredCIImageTransform);
    return [self newRenderedCGImageInRect:extent];
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

- (CGRect)scaleAndResizeDrawRect:(CGRect)rect forCIImage:(CIImage *)image
{
    if (self.scaleAndResizeCIImageAutomatically) {
        UIViewContentMode mode = self.contentMode;
        switch (mode) {
            case UIViewContentModeScaleAspectFill:
            case UIViewContentModeScaleAspectFit:
            {
                if (self.context.type == LFContextTypeEAGL) {
                    rect.origin.x = (rect.size.width - image.extent.size.width)/2;
                    rect.origin.y = (rect.size.height - image.extent.size.height)/2;
                    rect.size = image.extent.size;
                }
#if !(TARGET_IPHONE_SIMULATOR)
#ifdef NSFoundationVersionNumber_iOS_9_0
                else if (self.context.type == LFContextTypeMetal) {
                    rect.origin.x = -(rect.size.width - image.extent.size.width)/2;
                    rect.origin.y = -(rect.size.height - image.extent.size.height)/2;
                }
#endif
#endif
            }
                break;
            default:
                break;
        }
    }
    return rect;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if ((_CIImage != nil || _sampleBufferHolder.sampleBuffer != nil) && [self loadContextIfNeeded]) {
        if (@available(iOS 9.0, *)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            if (self.context.type == LFContextTypeCoreGraphics) {
                CIImage *image = [self renderedCIImageInRect:rect];
                
                if (image != nil) {
                    [_context.CIContext drawImage:image inRect:rect fromRect:image.extent];
                }
            }
#pragma clang diagnostic pop
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

static CGRect LF_CGRectMultiply(CGRect rect, CGFloat contentScale) {
    rect.origin.x *= contentScale;
    rect.origin.y *= contentScale;
    rect.size.width *= contentScale;
    rect.size.height *= contentScale;
    
    return rect;
}

#pragma mark -- GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    @autoreleasepool {
        glClearColor(0, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        if (self.contentView) {
            CGRect targetRect = [self convertRect:self.bounds toView:view];
            targetRect = LF_CGRectMultiply(targetRect, view.contentScaleFactor);

            /** OpenGL坐标变换 */
            rect = LF_CGRectMultiply(rect, view.contentScaleFactor);
            // 转换坐标
            CGFloat tranformX = targetRect.origin.x;
//            CGFloat tranformX = rect.size.width > targetRect.size.width ? (rect.size.width - targetRect.size.width) / 2 : targetRect.origin.x;
            CGFloat tranformY = rect.size.height - targetRect.size.height - targetRect.origin.y; // 反转y轴的滑动方向
            CGRect inRect = (CGRect){tranformX, tranformY, targetRect.size};

            CIImage *image = [self renderedCIImageInRect:inRect];

            // 优化：剪裁适合的尺寸，没有必要绘制超出rect范围的部分
            if (inRect.size.width > rect.size.width || inRect.size.height > rect.size.height) {
                CGFloat corpX = inRect.origin.x < 0 ? -inRect.origin.x : 0;
                CGFloat corpY = inRect.origin.y < 0 ? -inRect.origin.y : 0;

                CGFloat corpWidth = 0;
                if (corpX > 0) {
                    corpWidth = MIN(inRect.size.width+inRect.origin.x, rect.size.width);
                } else {
                    corpWidth = MIN(inRect.size.width, rect.size.width);
                }
                CGFloat corpHeight = 0;
                if (corpY > 0) {
                    corpHeight = MIN(inRect.size.height+inRect.origin.y, rect.size.height);
                } else {
                    corpHeight = MIN(inRect.size.height, rect.size.height);
                }

                inRect.origin.x += corpX;
                inRect.origin.y += corpY;
                inRect.size.width = corpWidth;
                inRect.size.height = corpHeight;

                image = [image imageByCroppingToRect:CGRectMake(corpX, corpY, corpWidth, corpHeight)];
            }

            if (image != nil) {
                [self scaleAndResizeDrawRect:rect forCIImage:image];
                [_context.CIContext drawImage:image inRect:inRect fromRect:image.extent];
            }

        } else {
            rect = LF_CGRectMultiply(rect, view.contentScaleFactor);

            CIImage *image = [self renderedCIImageInRect:rect];

            if (image != nil) {
                rect = [self scaleAndResizeDrawRect:rect forCIImage:image];
                [_context.CIContext drawImage:image inRect:rect fromRect:image.extent];
            }
        }
    }
}

#ifdef NSFoundationVersionNumber_iOS_9_0
#pragma mark -- MTKViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    @autoreleasepool {
        CGRect rect = LF_CGRectMultiply(view.bounds, self.contentScaleFactor);
        
        CIImage *image = [self renderedCIImageInRect:rect];
        
        if (image != nil) {
            rect = [self scaleAndResizeDrawRect:rect forCIImage:image];
            id<MTLCommandBuffer> commandBuffer = [_MTLCommandQueue commandBuffer];
            id<MTLTexture> texture = view.currentDrawable.texture;
            CGColorSpaceRef deviceRGB = CGColorSpaceCreateDeviceRGB();
            [_context.CIContext render:image toMTLTexture:texture commandBuffer:commandBuffer bounds:rect colorSpace:deviceRGB];
            [commandBuffer presentDrawable:view.currentDrawable];
            [commandBuffer commit];
            
            CGColorSpaceRelease(deviceRGB);
        }
    }
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}
#endif

@end
