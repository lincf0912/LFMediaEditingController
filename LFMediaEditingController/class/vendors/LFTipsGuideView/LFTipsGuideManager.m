//
//  LFTipsGuideManager.m
//  LFTipsGuideView
//
//  Created by TsanFeng Lam on 2020/2/4.
//  Copyright © 2020 lincf0912. All rights reserved.
//

#import "LFTipsGuideManager.h"

@interface LFTipsGuideManager ()

@property (nonatomic, strong) NSMutableDictionary *datas;
@property (nonatomic, copy) NSString *dataPath;

// 安全线程
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end

@implementation LFTipsGuideManager

+ (instancetype)manager
{
    static LFTipsGuideManager *m = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (m == nil) {
            m = [[LFTipsGuideManager alloc] init];
        }
    });
    return m;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _enable = YES;
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        _dataPath = [documentPath stringByAppendingPathComponent:@"LFTipsGuide.plist"];
        _serialQueue = dispatch_queue_create("LFTipsGuideManager.SerialQueue", DISPATCH_QUEUE_SERIAL);
        [self readData];
    }
    return self;
}

- (NSMutableDictionary *)datas
{
    if (_datas == nil) {
        _datas = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _datas;
}

- (void)readData
{
    dispatch_sync(self.serialQueue, ^{
        NSData *data = [NSData dataWithContentsOfFile:self.dataPath];
        if (data) {
            NSError *error;
            NSPropertyListFormat propertyListFormat = NSPropertyListBinaryFormat_v1_0;
            NSMutableDictionary *datas = [NSPropertyListSerialization propertyListWithData:data
                                                                                   options:NSPropertyListMutableContainersAndLeaves
                                                                                    format:&propertyListFormat
                                                                                     error:&error];
            if (error) {
                NSLog(@"LFTipsGuide read error:%@", error.localizedDescription);
            } else {
                self.datas = datas;
            }
        }
    });
}

- (void)saveData
{
    dispatch_sync(self.serialQueue, ^{
        NSError *error;
        NSData *data = [NSPropertyListSerialization dataWithPropertyList:self.datas
                                                                  format:NSPropertyListBinaryFormat_v1_0
                                                                 options:0
                                                                   error:&error];
        
        if (error) {
            NSLog(@"LFTipsGuide save error:%@", error.localizedDescription);
        } else {
            [data writeToFile:self.dataPath atomically:YES];
        }
    });
}

- (BOOL)isValidWithClass:(Class)aClass maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr
{
    NSMutableArray *rects = [NSMutableArray arrayWithCapacity:views.count];
    for (int i = 0; i < [views count]; i++) {
        UIView *view = views[i];
        CGRect maskRect = view.frame;
        maskRect.size = CGSizeMake(floor(maskRect.size.width + 10), floor(maskRect.size.height + 10));
        maskRect.origin = CGPointMake(floor(maskRect.origin.x - 5), floor(maskRect.origin.y - 5));
        [rects addObject:[NSValue valueWithCGRect:maskRect]];
    }
    
    return [self isValidWithClass:aClass maskRects:rects withTips:tipsArr];
}

- (BOOL)isValidWithClass:(Class)aClass maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr
{
    if (self.isEnable) {    
        NSString *mainKey = [self getMainKeyWithClass:aClass];
        if (mainKey.length) {
            NSMutableDictionary *subDatas = [self.datas objectForKey:mainKey];
            if (subDatas == nil) {
                return NO;
            }
            NSString *subKey = [self getSubKeyWithRects:rects withTips:tipsArr];
            NSInteger times = [[subDatas objectForKey:subKey] integerValue];
            
            if (times > 0) {
                times--;
                if (times == 0) {
                    times = -1; // 标记已使用完毕
                }
                [subDatas setObject:@(times) forKey:subKey];
                [self saveData];
                return YES;
            } else if (times == 0) { // 总是可用
                return YES;
            }
        }
    }
    return NO;
}

- (void)writeClass:(Class)aClass maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times
{
    NSMutableArray *rects = [NSMutableArray arrayWithCapacity:views.count];
    for (int i = 0; i < [views count]; i++) {
        UIView *view = views[i];
        CGRect maskRect = view.frame;
        maskRect.size = CGSizeMake(floor(maskRect.size.width + 10), floor(maskRect.size.height + 10));
        maskRect.origin = CGPointMake(floor(maskRect.origin.x - 5), floor(maskRect.origin.y - 5));
        [rects addObject:[NSValue valueWithCGRect:maskRect]];
    }
    [self writeClass:aClass maskRects:rects withTips:tipsArr times:times];
}

- (void)writeClass:(Class)aClass maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr times:(NSUInteger)times
{
    NSString *mainKey = [self getMainKeyWithClass:aClass];
    if (mainKey.length) {
        NSMutableDictionary *subDatas = [self.datas objectForKey:mainKey];
        if (subDatas == nil) {
            subDatas = [NSMutableDictionary dictionary];
            [self.datas setObject:subDatas forKey:mainKey];
        }
        NSString *subKey = [self getSubKeyWithRects:rects withTips:tipsArr];
        if (![subDatas.allKeys containsObject:subKey]) {
            [subDatas setObject:@(times) forKey:subKey];
            [self saveData];
        }
    }
}

- (void)removeClass:(Class)aClass maskViews:(NSArray <UIView *>*)views withTips:(NSArray <NSString *>*)tipsArr
{
    NSMutableArray *rects = [NSMutableArray arrayWithCapacity:views.count];
    for (int i = 0; i < [views count]; i++) {
        UIView *view = views[i];
        CGRect maskRect = view.frame;
        maskRect.size = CGSizeMake(floor(maskRect.size.width + 10), floor(maskRect.size.height + 10));
        maskRect.origin = CGPointMake(floor(maskRect.origin.x - 5), floor(maskRect.origin.y - 5));
        [rects addObject:[NSValue valueWithCGRect:maskRect]];
    }
    [self removeClass:aClass maskRects:rects withTips:tipsArr];
}

- (void)removeClass:(Class)aClass maskRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr
{
    NSString *mainKey = [self getMainKeyWithClass:aClass];
    if (mainKey.length) {
        NSMutableDictionary *subDatas = [self.datas objectForKey:mainKey];
        if (subDatas == nil) {
            return;
        }
        NSString *subKey = [self getSubKeyWithRects:rects withTips:tipsArr];
        [subDatas removeObjectForKey:subKey];
        if (subDatas.count == 0) {
            [self.datas removeObjectForKey:mainKey];
        }
        [self saveData];
    }
}

- (void)removeClass:(Class)aClass
{
    NSString *mainKey = [self getMainKeyWithClass:aClass];
    if (mainKey.length) {
        [self.datas removeObjectForKey:mainKey];
        [self saveData];
    }
}

#pragma mark - private
- (NSString *)getMainKeyWithClass:(Class)aClass
{
    NSString *className = NSStringFromClass(aClass);
    NSData *data = [className dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

- (NSString *)getSubKeyWithRects:(NSArray <NSValue *>*)rects withTips:(NSArray <NSString *>*)tipsArr
{
    NSMutableString *subKey = [NSMutableString stringWithString:@""];
//    for (NSValue *value in rects) {
//        [subKey appendString:NSStringFromCGRect([value CGRectValue])];
//    }
    [subKey appendFormat:@"%@|%@", [rects componentsJoinedByString:@","], [tipsArr componentsJoinedByString:@","]];
    
    NSData *data = [subKey dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

@end
