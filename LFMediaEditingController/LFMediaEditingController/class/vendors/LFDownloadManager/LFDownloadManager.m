//
//  LFDownloadManager.m
//  LFPhotoBrowserDEMO
//
//  Created by TsanFeng Lam on 2017/12/11.
//  Copyright © 2017年 GZMiracle. All rights reserved.
//

#import "LFDownloadManager.h"
#import <objc/runtime.h>

#define LFDownloadManagerDirector [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:NSStringFromClass([self class])]
#define LFDownloadManagerDirectorAppending(name) [LFDownloadManagerDirector stringByAppendingPathComponent:name]

#pragma mark - //////////////   LFDownloadInfo

@interface LFDownloadInfo ()

@property (nonatomic, weak) NSOperation *operation;

@end

@implementation LFDownloadInfo

+ (instancetype)lf_downloadInfoWithURL:(NSURL *)downloadURL
{
    LFDownloadInfo *info = [[[self class] alloc] init];
    info.downloadURL = downloadURL;
    return info;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadTimes = 1;
    }
    return self;
}

- (BOOL)reDownload
{
    return _downloadTimes > 1;
}

@end

#pragma mark - //////////////   LFURLSessionOperation

static const char * LFURLSessionOperationKey = "LFURLSessionOperationKey";

@class LFURLSessionOperation;
@interface NSURLSessionTask (LFURLSessionOperation)

@property (nonatomic, weak) LFURLSessionOperation *lf_operation;

@end

@implementation NSURLSessionTask (LFURLSessionOperation)

- (LFURLSessionOperation *)lf_operation
{
    return objc_getAssociatedObject(self, LFURLSessionOperationKey);
}

- (void)setLf_operation:(LFURLSessionOperation *)lf_operation
{
    objc_setAssociatedObject(self, LFURLSessionOperationKey, lf_operation, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface LFURLSessionOperation : NSOperation

- (instancetype)initWithDataSession:(NSURLSession *)session URL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;
- (instancetype)initWithDataSession:(NSURLSession *)session request:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

- (instancetype)initWithDownloadSession:(NSURLSession *)session URL:(NSURL *)URL;

@property (nonatomic, strong, readonly) NSURLSessionTask *task;

- (void)completeOperation;

@end

@implementation LFURLSessionOperation
{
    BOOL _finished;
    BOOL _executing;
}

- (instancetype)initWithDataSession:(NSURLSession *)session URL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        _task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [weakSelf completeOperationWithBlock:completionHandler data:data response:response error:error];
        }];
    }
    return self;
}

- (instancetype)initWithDataSession:(NSURLSession *)session request:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        _task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [weakSelf completeOperationWithBlock:completionHandler data:data response:response error:error];
        }];
    }
    return self;
}

- (instancetype)initWithDownloadSession:(NSURLSession *)session URL:(NSURL *)URL
{
    if (self = [super init]) {
        _task = [session downloadTaskWithURL:URL];
        _task.lf_operation = self;
    }
    return self;
}

- (void)cancel {
    [super cancel];
    [self.task cancel];
}

- (void)start {
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    [self willChangeValueForKey:@"isExecuting"];
        [self.task resume];
        _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isAsynchronous
{
    return YES;
}

- (void)completeOperationWithBlock:(void (^)(NSData *, NSURLResponse *, NSError *))block data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    if (block)
        block(data, response, error);
    [self completeOperation];
}

- (void)completeOperationWithBlock:(void (^)(NSURL *, NSURLResponse *, NSError *))block url:(NSURL *)url response:(NSURLResponse *)response error:(NSError *)error {
    if (block)
        block(url, response, error);
    [self completeOperation];
}

- (void)completeOperation {
    _task.lf_operation = nil;
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    _executing = NO;
    _finished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

#pragma mark - //////////////   LFDownloadManager

@interface LFDownloadManager() <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableDictionary *downloadDictionary;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation LFDownloadManager

+ (void)initialize {
    
    NSString *directory = LFDownloadManagerDirector;
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExists = [fileManager fileExistsAtPath:directory isDirectory:&isDirectory];
    if (!isExists || !isDirectory) {
        [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (LFDownloadManager *)shareLFDownloadManager
{
    static LFDownloadManager *share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [LFDownloadManager new];
    });
    return share;
}

- (NSMutableDictionary <NSURL *,  NSMutableArray<LFDownloadInfo *>*>*)downloadDictionary {
    
    if (!_downloadDictionary) {
        _downloadDictionary = @{}.mutableCopy;
    }
    return _downloadDictionary;
}

- (instancetype)init {
    
    if (self = [super init]) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 5;
        _repeatCountWhenDownloadFailed = 2;
        _cacheData = YES;
    }
    return self;
}

- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
{
    self.queue.maxConcurrentOperationCount = maxConcurrentOperationCount;
}

- (NSInteger)maxConcurrentOperationCount
{
    return self.queue.maxConcurrentOperationCount;
}

- (NSString *)sandboxNameWithURL:(NSURL *)URL
{
    NSData *encodeData = [URL.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [encodeData base64EncodedStringWithOptions:0];
    return base64String;
}

- (NSData *)dataFromSandboxWithURL:(NSURL *)URL
{
    NSString *path = LFDownloadManagerDirectorAppending([self sandboxNameWithURL:URL]);
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data.length > 0 ) {
        return data;
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
    return nil;
}

- (void)lf_requestGetURL:(NSURL *)URL completion:(lf_completeBlock)completion
{
    //创建请求对象
    //请求对象内部默认已经包含了请求头和请求方法（GET）
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    LFURLSessionOperation *operation = [[LFURLSessionOperation alloc] initWithDataSession:self.session request:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completion) {
            completion(data, error, URL);
        }
    }];
    
    //执行任务
    [self.queue addOperation:operation];
}

- (void)lf_downloadURL:(NSURL *)URL progress:(lf_progressBlock)progress completion:(lf_completeBlock)completion
{
    LFDownloadInfo *info = [LFDownloadInfo lf_downloadInfoWithURL:URL];
    [self lf_downloadInfo:info progress:progress completion:completion];
}

- (void)lf_downloadInfo:(LFDownloadInfo *)info progress:(lf_progressBlock)progress completion:(lf_completeBlock)completion
{
    NSURL *URL = info.downloadURL;
    info.progress = [progress copy];
    info.complete = [completion copy];
    NSMutableArray <LFDownloadInfo *>* downloadList = self.downloadDictionary[URL];
    if (downloadList == nil) {
        downloadList = [NSMutableArray array];
        [downloadList addObject:info];
        self.downloadDictionary[URL] = downloadList;
        [self downloadInfo:info];
    } else {
        [downloadList addObject:info];
    }
}

- (BOOL)redownloadURL:(NSURL *)URL error:(NSError *)error
{
    NSMutableArray <LFDownloadInfo *>* downloadList = self.downloadDictionary[URL];
    for (NSInteger i=0; i<downloadList.count; i++) {
        LFDownloadInfo *info = downloadList[i];
        NSInteger downloadTimes = info.downloadTimes;
        if (self.repeatCountWhenDownloadFailed > downloadTimes) {
            info.downloadTimes++;
        } else {
            if (info.complete) {
                info.complete(nil, error, info.downloadURL);
            }
            info.complete = nil;
            info.progress = nil;
            [downloadList removeObject:info];
            i--;
        }
    }
    
    if (downloadList.count) {
        [self downloadInfo:downloadList.firstObject];
        return YES;
    }
    
    return NO;
}

- (void)downloadInfo:(LFDownloadInfo *)info
{
    NSURL *URL = info.downloadURL;
    NSData *data = [self dataFromSandboxWithURL:URL];
    if (data) {
        NSMutableArray <LFDownloadInfo *>* downloadList = self.downloadDictionary[URL];
        for (LFDownloadInfo *info in downloadList) {
            if (info.progress) {
                info.progress(data.length, data.length, info.downloadURL);
            }
            if (info.complete) {
                info.complete(data, nil, info.downloadURL);
            }
            info.complete = nil;
            info.progress = nil;
        }
        [self.downloadDictionary removeObjectForKey:URL];
        return;
    }
    
    // 2、利用NSURLSessionDownloadTask创建任务(task)
    LFURLSessionOperation *operation = [[LFURLSessionOperation alloc] initWithDownloadSession:self.session URL:URL];
    info.operation = operation;
    // 3、执行任务
    [self.queue addOperation:operation];
}

- (void)lf_downloadCancelInfo:(LFDownloadInfo *)info
{
    if (info == nil) {
        return;
    }
    NSURL *URL = info.downloadURL;
    NSMutableArray <LFDownloadInfo *>* downloadList = self.downloadDictionary[URL];
    if ([downloadList containsObject:info]) {
        [downloadList removeObject:info];
        info.complete = nil;
        info.progress = nil;
    }
    
    if (downloadList.count == 0) {
        [self.downloadDictionary removeObjectForKey:URL];
    }
}

- (void)lf_cancelWithURL:(NSURL *)URL
{
    NSMutableArray <LFDownloadInfo *>* downloadList = self.downloadDictionary[URL];
    NSOperation *operation = downloadList.firstObject.operation;
    for (LFDownloadInfo *info in downloadList) {
        info.complete = nil;
        info.progress = nil;
    }
    [operation cancel];
    [self.downloadDictionary removeObjectForKey:URL];
}

- (void)lf_cancel
{
    [self.queue cancelAllOperations];
}

+ (void)lf_clearCached {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileNames = [fileManager contentsOfDirectoryAtPath:LFDownloadManagerDirector error:nil];
    for (NSString *fileName in fileNames) {
        if (![fileManager removeItemAtPath:[LFDownloadManagerDirector stringByAppendingPathComponent:fileName] error:nil]) {
            NSLog(@"removeItemAtPath Failed!");
        }
    }
}

#pragma mark - NSURLSessionDownloadDelegate
/*
 1.接收到服务器返回的数据
 bytesWritten: 当前这一次写入的数据大小
 totalBytesWritten: 已经写入到本地文件的总大小
 totalBytesExpectedToWrite : 被下载文件的总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //给progressView赋值进度
//    self.progressView.progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    NSURL *URL = downloadTask.originalRequest.URL;
    
    NSMutableArray <LFDownloadInfo *>* downloadList = self.downloadDictionary[URL];
    for (LFDownloadInfo *info in downloadList) {
        if (info.progress) {
            info.progress(totalBytesWritten, totalBytesExpectedToWrite, info.downloadURL);
        }
    }
}

/*
 2.下载完成
 downloadTask:里面包含请求信息，以及响应信息
 location：下载后自动帮我保存的地址
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    //location为下载好的文件路径
    //NSLog(@"didFinishDownloadingToURL, %@", location);
    [downloadTask.lf_operation completeOperation];
    NSURL *URL = downloadTask.originalRequest.URL;
    
    
    NSData *data = [NSData dataWithContentsOfURL:location];
    if (self.cacheData) {
        //1、生成的Caches地址
        NSString *cacepath = LFDownloadManagerDirectorAppending([self sandboxNameWithURL:URL]);
        //2、移动图片的存储地址
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager moveItemAtURL:location toURL:[NSURL fileURLWithPath:cacepath] error:nil];
    }
    
    NSMutableArray <LFDownloadInfo *>* downloadList = self.downloadDictionary[URL];
    for (LFDownloadInfo *info in downloadList) {
        if (info.complete) {
            info.complete(data, nil, info.downloadURL);
        }
        info.complete = nil;
        info.progress = nil;
    }
    [self.downloadDictionary removeObjectForKey:URL];
}

/*
 3.请求完毕
 如果有错误, 那么error有值
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [task.lf_operation completeOperation];
    if (error) {
        NSURL *URL = task.originalRequest.URL;
        if (task.state == NSURLSessionTaskStateCanceling) {
            NSMutableArray <LFDownloadInfo *>* downloadList = self.downloadDictionary[URL];
            for (LFDownloadInfo *info in downloadList) {
                info.complete = nil;
                info.progress = nil;
            }
            [self.downloadDictionary removeObjectForKey:URL];
            return;
        }
        
        
        if (![self redownloadURL:URL error:error]) {
            
            NSMutableArray <LFDownloadInfo *>* downloadList = self.downloadDictionary[URL];
            for (LFDownloadInfo *info in downloadList) {
                if (info.complete) {
                    info.complete(nil, error, info.downloadURL);
                }
                info.complete = nil;
                info.progress = nil;
            }
            [self.downloadDictionary removeObjectForKey:URL];
        }
    }
}
@end
