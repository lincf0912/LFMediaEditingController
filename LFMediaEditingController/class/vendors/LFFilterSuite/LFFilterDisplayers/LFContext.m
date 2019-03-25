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
        _type = LFContextTypeDefault;
    }
    
    return self;
}

- (instancetype)initWithCGContextRef:(CGContextRef)contextRef {
    self = [super init];
    
    if (self) {
        if (@available(iOS 9.0, *)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
            _CIContext = [CIContext contextWithCGContext:contextRef options:LFContextCreateCIContextOptions()];
#pragma clang diagnostic pop            
        }
        _type = LFContextTypeCoreGraphics;
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

+ (LFContextType)suggestedContextType {
    if ([self supportsType:LFContextTypeEAGL]) {
        return LFContextTypeEAGL;
    } else if ([self supportsType:LFContextTypeCoreGraphics]) {
        return LFContextTypeCoreGraphics;
    } else {
        return LFContextTypeDefault;
    }
}

+ (BOOL)supportsType:(LFContextType)contextType {
    id CIContextClass = [CIContext class];
    
    switch (contextType) {
        case LFContextTypeCoreGraphics:
            return [CIContextClass respondsToSelector:@selector(contextWithCGContext:options:)];
        case LFContextTypeEAGL:
            return [CIContextClass respondsToSelector:@selector(contextWithEAGLContext:options:)];
        case LFContextTypeAuto:
        case LFContextTypeDefault:
            return YES;
    }
    return NO;
}

+ (LFContext *__nonnull)contextWithType:(LFContextType)type options:(NSDictionary *__nullable)options {
    switch (type) {
        case LFContextTypeAuto:
            return [self contextWithType:[self suggestedContextType] options:options];
        case LFContextTypeCoreGraphics: {
            CGContextRef context = (__bridge CGContextRef)(options[LFContextOptionsCGContextKey]);
            
            if (context == nil) {
                [NSException raise:@"MissingCGContext" format:@"LFContextTypeCoreGraphics needs to have a CGContext attached to the LFContextOptionsCGContextKey in the options"];
            }
            
            return [[self alloc] initWithCGContextRef:context];
        }
        case LFContextTypeDefault: {
            NSMutableDictionary *options = LFContextCreateCIContextOptions().mutableCopy;
            options[kCIContextUseSoftwareRenderer] = @(NO);
            return [[self alloc] initWithSoftwareRenderer:NO];
        }
        case LFContextTypeEAGL: {
            EAGLContext *context = options[LFContextOptionsEAGLContextKey];
            
            if (context == nil) {
                static dispatch_once_t onceToken;
                static EAGLSharegroup *shareGroup;
                dispatch_once(&onceToken, ^{
                    shareGroup = [EAGLSharegroup new];
                });
                
                context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:shareGroup];
            }
            
            return [[self alloc] initWithEAGLContext:context];
        }
        default:
            [NSException raise:@"InvalidContextType" format:@"Invalid context type %d", (int)type];
            break;
    }
    
    return nil;
}

@end
