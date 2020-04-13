//
//  LFBrushCache.m
//  LFMediaEditingController
//
//  Created by TsanFeng Lam on 2019/9/6.
//  Copyright © 2019 LamTsanFeng. All rights reserved.
//

#import "LFBrushCache.h"
#import <UIKit/UIKit.h>

@interface LFBrushCache ()

@property (nonatomic, strong) NSMutableDictionary *forceCache;

@end

@implementation LFBrushCache

static LFBrushCache *lf_BrushCacheShare = nil;
+ (instancetype)share
{
    if (lf_BrushCacheShare == nil) {
        lf_BrushCacheShare = [[LFBrushCache alloc] init];
        lf_BrushCacheShare.name = @"BrushCache";
    }
    return lf_BrushCacheShare;
}

+ (void)free
{
    [lf_BrushCacheShare removeAllObjects];
    lf_BrushCacheShare = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _forceCache = [NSMutableDictionary dictionary];
        //收到系统内存警告后直接调用 removeAllObjects 删除所有缓存对象
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)setForceObject:(id)obj forKey:(id)key
{
    [self.forceCache setObject:obj forKey:key];
}

- (void)removeObjectForKey:(id)key
{
    [self.forceCache removeObjectForKey:key];
    [super removeObjectForKey:key];
}

- (id)objectForKey:(id)key
{
    id obj = [self.forceCache objectForKey:key];
    if (obj) {
        return obj;
    }
    return [super objectForKey:key];
}

- (void)removeAllObjects
{
    [self.forceCache removeAllObjects];
    [super removeAllObjects];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end
