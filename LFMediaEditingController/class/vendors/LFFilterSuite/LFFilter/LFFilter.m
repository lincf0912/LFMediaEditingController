//
//  LFFilter.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/3/1.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFFilter.h"

@interface LFFilter ()

@property (strong, nonatomic) CIImage *overlayImage;

@property (copy, nonatomic) LFFilterHandle filterHandle;

@end

@implementation LFFilter

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        self.enabled = YES;
    }
    
    return self;
}

- (instancetype)initWithCIFilter:(CIFilter *)filter {
    self = [self init];
    
    if (self) {
        _name = [filter.attributes objectForKey:kCIAttributeFilterDisplayName];
        _CIFilter = filter;
    }
    
    return self;
}

- (void)resetToDefaults {
    [_CIFilter setDefaults];
}

- (BOOL)isEmpty {
    BOOL isEmpty = YES;
    
    if (_CIFilter != nil || _overlayImage != nil) {
        return NO;
    }
    
    return isEmpty;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    
    if (self) {
        _CIFilter = [aDecoder decodeObjectForKey:@"CoreImageFilter"];
        self.enabled = [aDecoder decodeBoolForKey:@"Enabled"];
        
        if ([aDecoder containsValueForKey:@"VectorsData"]) {
            NSArray *vectors = [aDecoder decodeObjectForKey:@"VectorsData"];
            for (NSArray *vectorData in vectors) {
                CGFloat *vectorValue = malloc(sizeof(CGFloat) * (vectorData.count - 1));
                
                if (vectorData != nil) {
                    for (int i = 1; i < vectorData.count; i++) {
                        NSNumber *value = [vectorData objectAtIndex:i];
                        vectorValue[i - 1] = (CGFloat)value.doubleValue;
                    }
                    NSString *key = vectorData.firstObject;
                    
                    [_CIFilter setValue:[CIVector vectorWithValues:vectorValue count:vectorData.count - 1] forKey:key];
                    free(vectorValue);
                }
            }
        }
        
        if ([aDecoder containsValueForKey:@"Name"]) {
            _name = [aDecoder decodeObjectForKey:@"Name"];
        } else {
            _name = [_CIFilter.attributes objectForKey:kCIAttributeFilterName];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    CIFilter *copiedFilter = _CIFilter.copy;
    
    if (copiedFilter != nil) {
        [aCoder encodeObject:copiedFilter forKey:@"CoreImageFilter"];
    }
    
    [aCoder encodeBool:self.enabled forKey:@"Enabled"];
    
    NSMutableArray *vectors = [NSMutableArray new];
    
    for (NSString *key in _CIFilter.inputKeys) {
        id value = [_CIFilter valueForKey:key];
        
        if ([value isKindOfClass:[CIVector class]]) {
            CIVector *vector = value;
            NSMutableArray *vectorData = [NSMutableArray new];
            [vectorData addObject:key];
            
            for (int i = 0; i < vector.count; i++) {
                CGFloat value = [vector valueAtIndex:i];
                [vectorData addObject:[NSNumber numberWithDouble:(double)value]];
            }
            [vectors addObject:vectorData];
        }
    }
    
    [aCoder encodeObject:vectors forKey:@"VectorsData"];
    
    [aCoder encodeObject:_name forKey:@"Name"];

}

- (CIImage *)imageByProcessingImage:(CIImage *)image {
    return [self imageByProcessingImage:image atTime:0];
}

- (CIImage *)imageByProcessingImage:(CIImage *)image atTime:(CFTimeInterval)time {
    if (!self.enabled) {
        return image;
    }
    
    CIImage *overlayImage = _overlayImage;
    if (overlayImage != nil) {
        image = [overlayImage imageByCompositingOverImage:image];
    }
    
    if (self.filterHandle) {
        image = self.filterHandle(image);
    }
    
    CIFilter *ciFilter = _CIFilter;
    
    if (ciFilter == nil) {
        return image;
    }
    
    [ciFilter setValue:image forKey:kCIInputImageKey];
    return [ciFilter valueForKey:kCIOutputImageKey];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    LFFilter *filter = [[self.class alloc] initWithCIFilter:nil];
    
    if (filter != nil) {
        filter->_name = [_name copy];
        filter->_CIFilter = [_CIFilter copy];
    }
    
    return filter;
}

#pragma mark - Initialize
+ (LFFilter *)emptyFilter {
    return [[self class] filterWithCIFilter:nil];
}

+ (LFFilter *)filterWithCIFilter:(CIFilter *)filterDescription {
    return [[[self class] alloc] initWithCIFilter:filterDescription];
}

+ (LFFilter *)filterWithCIFilterName:(NSString *)name {
    CIFilter *coreImageFilter = [CIFilter filterWithName:name];
    [coreImageFilter setDefaults];
    
    return coreImageFilter != nil ? [[self class] filterWithCIFilter:coreImageFilter] : nil;
}


+ (LFFilter *)filterWithAffineTransform:(CGAffineTransform)affineTransform {
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform"];
    [filter setValue:[NSValue valueWithBytes:&affineTransform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    return [[self class] filterWithCIFilter:filter];
}


+ (LFFilter *)filterWithData:(NSData *)data {
    return [[self class] filterWithData:data error:nil];
}

+ (LFFilter *)filterWithData:(NSData *)data error:(NSError *__autoreleasing *)error {
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    } @catch (NSException *exception) {
        if (error != nil) {
            *error = [NSError errorWithDomain:@"LFFilterGroup" code:200 userInfo:@{
                                                                                   NSLocalizedDescriptionKey : exception.reason
                                                                                   }];
            return nil;
        }
    }
    
    if (![obj isKindOfClass:[LFFilter class]]) {
        obj = nil;
        if (error != nil) {
            *error = [NSError errorWithDomain:@"LFFilterDomain" code:200 userInfo:@{
                                                                                  NSLocalizedDescriptionKey : @"Invalid serialized class type"
                                                                                  }];
        }
    }
    
    return obj;
}

+ (LFFilter *)filterWithContentsOfURL:(NSURL *)url {
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if (data != nil) {
        return [[self class] filterWithData:data];
    }
    
    return nil;
}


+ (LFFilter *)filterWithCIImage:(CIImage *)image {
    LFFilter *filter = [[self class] emptyFilter];
    filter.overlayImage = image;
    
    return filter;
}

+ (LFFilter *)filterWithBlock:(LFFilterHandle)block {
    LFFilter *filter = [[self class] emptyFilter];
    filter.filterHandle = [block copy];
    
    return filter;
}

@end
