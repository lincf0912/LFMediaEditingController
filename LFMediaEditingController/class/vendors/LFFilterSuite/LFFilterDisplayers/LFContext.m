//
//  LFContext.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFContext.h"


NSString *__nonnull const LFContextOptionsCGContextKey = @"CGContext";
NSString *__nonnull const LFContextOptionsEAGLContextKey = @"EAGLContext";
NSString *__nonnull const LFContextOptionsMTLDeviceKey = @"MTLDevice";

static NSDictionary *LFContextCreateCIContextOptions() {
    return @{kCIContextWorkingColorSpace : [NSNull null], kCIContextOutputColorSpace : [NSNull null]};
}


@implementation LFContext

- (instancetype)initWithSoftwareRenderer:(BOOL)softwareRenderer {
    self = [super init];
    
    if (self) {
        NSMutableDictionary *options = LFContextCreateCIContextOptions().mutableCopy;
        options[kCIContextUseSoftwareRenderer] = @(softwareRenderer);
        _CIContext = [CIContext contextWithOptions:options];
        if (softwareRenderer) {
            _type = LFContextTypeCPU;
        } else {
            _type = LFContextTypeDefault;
        }
    }
    
    return self;
}

- (instancetype)initWithCGContextRef:(CGContextRef)contextRef {
    self = [super init];
    
    if (self) {
        if (@available(iOS 9.0, *)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            _CGContext = contextRef;
            _CIContext = [CIContext contextWithCGContext:contextRef options:LFContextCreateCIContextOptions()];
            _type = LFContextTypeCoreGraphics;
#pragma clang diagnostic pop
        }
    }
    
    return self;
}

- (instancetype)initWithEAGLContext:(EAGLContext *)context {
    self = [super init];
    
    if (self) {
        _EAGLContext = context;
        
        _CIContext = [CIContext contextWithEAGLContext:_EAGLContext options:LFContextCreateCIContextOptions()];
        _type = LFContextTypeEAGL;
    }
    
    return self;
}

- (instancetype)initWithLargeImageContext:(EAGLContext *)context {
    self = [super init];
    
    if (self) {
        _EAGLContext = context;
        
        _CIContext = [CIContext contextWithEAGLContext:_EAGLContext options:LFContextCreateCIContextOptions()];
        _type = LFContextTypeLargeImage;
    }
    
    return self;
}

- (instancetype)initWithMTLDevice:(id<MTLDevice>)device {
    self = [super init];
    
    if (self) {
        _MTLDevice = device;
        if (@available(iOS 9.0, *)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            _CIContext = [CIContext contextWithMTLDevice:device options:LFContextCreateCIContextOptions()];
            _type = LFContextTypeMetal;
#pragma clang diagnostic pop
        }
    }
    
    return self;
}

+ (LFContextType)suggestedContextType {

    if ([self supportsType:LFContextTypeEAGL]) {
        return LFContextTypeEAGL;
    } else
        // On iOS 9.0, Metal does not behave nicely with gaussian blur filters
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wunguarded-availability"
//        if ([self supportsType:LFContextTypeMetal]) {
//            return LFContextTypeMetal;
//        } else
//#pragma clang diagnostic pop
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
        if ([self supportsType:LFContextTypeCoreGraphics]) {
            return LFContextTypeCoreGraphics;
#pragma clang diagnostic pop
    } else {
        return LFContextTypeDefault;
    }
}

+ (BOOL)supportsType:(LFContextType)contextType {
    id CIContextClass = [CIContext class];
    
    switch (contextType) {
        case LFContextTypeMetal:
            return [CIContextClass respondsToSelector:@selector(contextWithMTLDevice:options:)];
        case LFContextTypeCoreGraphics:
            return [CIContextClass respondsToSelector:@selector(contextWithCGContext:options:)];
        case LFContextTypeEAGL:
        case LFContextTypeLargeImage:
            return [CIContextClass respondsToSelector:@selector(contextWithEAGLContext:options:)];
        case LFContextTypeAuto:
        case LFContextTypeDefault:
        case LFContextTypeCPU:
            return YES;
    }
    return NO;
}

+ (LFContext *__nonnull)contextWithType:(LFContextType)type options:(NSDictionary *__nullable)options {
    switch (type) {
        case LFContextTypeAuto:
            return [self contextWithType:[self suggestedContextType] options:options];
        case LFContextTypeMetal: {
            if (@available(iOS 8.0, *)) {
                id<MTLDevice> device = options[LFContextOptionsMTLDeviceKey];
                if (device == nil) {
                    device = MTLCreateSystemDefaultDevice();
                }
                if (device == nil) {
                    [NSException raise:@"Metal Error" format:@"Metal is available on iOS 8 and A7 chips. Or higher."];
                }
                
                return [[self alloc] initWithMTLDevice:device];
            }
        }
        case LFContextTypeCoreGraphics: {
            CGContextRef context = (__bridge CGContextRef)(options[LFContextOptionsCGContextKey]);
            
            if (context == nil) {
                [NSException raise:@"MissingCGContext" format:@"LFContextTypeCoreGraphics needs to have a CGContext attached to the LFContextOptionsCGContextKey in the options"];
            }
            
            return [[self alloc] initWithCGContextRef:context];
        }
        case LFContextTypeCPU:
            return [[self alloc] initWithSoftwareRenderer:YES];
        case LFContextTypeDefault:
            return [[self alloc] initWithSoftwareRenderer:NO];
        case LFContextTypeEAGL:
        case LFContextTypeLargeImage:
        {
            EAGLContext *context = options[LFContextOptionsEAGLContextKey];
            
            if (context == nil) {
                static dispatch_once_t onceToken;
                static EAGLSharegroup *shareGroup;
                dispatch_once(&onceToken, ^{
                    shareGroup = [EAGLSharegroup new];
                });
                
                context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:shareGroup];
            }
            
            if (type == LFContextTypeEAGL) {
                return [[self alloc] initWithEAGLContext:context];
            } else if (type == LFContextTypeLargeImage) {
                return [[self alloc] initWithLargeImageContext:context];
            }
        }
        default:
            [NSException raise:@"InvalidContextType" format:@"Invalid context type %d", (int)type];
            break;
    }
    
    return nil;
}

@end
