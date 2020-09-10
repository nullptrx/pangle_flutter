// The MIT License (MIT)
//
// Copyright (c) 2015-2016 NBL ( https://github.com/yjh4866/SimplifiedAFN )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "NBLHTTPFileManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "NBLHTTPManager.h"


#define FilePath(url)   [NSTemporaryDirectory() stringByAppendingPathComponent:transferFileNameFromURL(url)]
#define FilePath_Temp(filePath)   [filePath stringByAppendingPathExtension:NSClassFromString(@"NSURLSession")?@"NBLNewTempFile":@"NBLTempFile"]


// 将url转换为文件名
NSString *transferFileNameFromURL(NSString *url)
{
    if ([url isKindOfClass:NSString.class] && url.length > 0) {
        // 将url字符MD5处理
        const char *cStr = [url UTF8String];
        unsigned char result[16];
        CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
        NSString *fileName = [NSString stringWithFormat:
                              @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                              result[0], result[1], result[2], result[3],
                              result[4], result[5], result[6], result[7],
                              result[8], result[9], result[10], result[11],
                              result[12], result[13], result[14], result[15]];
        // 加上后缀名
        NSString *pathExtension = [[NSURL URLWithString:url] pathExtension];
        if (pathExtension.length > 0) {
            fileName = [fileName stringByAppendingPathExtension:pathExtension];
        }
        return fileName;
    }
    return @"";
}


#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0

#pragma mark -
#pragma mark - NSURLConnection方案
#pragma mark -

typedef NS_ENUM(unsigned int, NBLHTTPFileTaskStatus) {
    NBLHTTPFileTaskStatus_Canceling = 1,
    NBLHTTPFileTaskStatus_Waiting,
    NBLHTTPFileTaskStatus_GetFileSize,
    NBLHTTPFileTaskStatus_GetFileData,
    NBLHTTPFileTaskStatus_Finished,
};

static inline NSString * KeyPathFromHTTPFileTaskStatus(NBLHTTPFileTaskStatus state) {
    switch (state) {
        case NBLHTTPFileTaskStatus_Canceling:
            return @"isCanceling";
        case NBLHTTPFileTaskStatus_Waiting:
            return @"isWaiting";
        case NBLHTTPFileTaskStatus_GetFileSize:
            return @"isGettingFileSize";
        case NBLHTTPFileTaskStatus_GetFileData:
            return @"isGettingFileData";
        case NBLHTTPFileTaskStatus_Finished:
            return @"isFinished";
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            return @"state";
#pragma clang diagnostic pop
        }
    }
}


static dispatch_queue_t httpfile_operation_headcompletion_queue() {
    static dispatch_queue_t httpfile_operation_headcompletion_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpfile_operation_headcompletion_queue = dispatch_queue_create("com.yjh4866.httpfile.completion.head.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return httpfile_operation_headcompletion_queue;
}
static dispatch_queue_t httpfile_operation_completion_queue() {
    static dispatch_queue_t httpfile_operation_completion_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpfile_operation_completion_queue = dispatch_queue_create("com.yjh4866.httpfile.completion.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return httpfile_operation_completion_queue;
}


#pragma mark -  NBLHTTPManager (NBLHTTPFileManager)

@interface  NBLHTTPManager (Private)
// 根据NSURLRequest获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType
          withRequest:(NSURLRequest *)request param:(NSDictionary *)dicParam
             progress:(NBLHTTPProgress)progress andResult:(NBLHTTPResult)result
    onCompletionQueue:(dispatch_queue_t)completionQueue;
@end
@implementation NBLHTTPManager (NBLHTTPFileManager)
// NBLHTTPFileManager的专用单例
+ (NBLHTTPManager *)sharedManagerForHTTPFileManger
{
    static NBLHTTPManager *sharedManagerForHTTPFileManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManagerForHTTPFileManger = [[NBLHTTPManager alloc] init];
    });
    return sharedManagerForHTTPFileManger;
}
@end


typedef void (^Block_Void)();

#pragma mark - NBLHTTPFileTaskOperation

@interface NBLHTTPFileTaskOperation : NSOperation
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, strong) NSDictionary *param;
@property (nonatomic, assign) int64_t bytesReceived;
@property (nonatomic, assign) int64_t totalBytes;
@property (nonatomic, strong) NSMutableDictionary *mdicSubTaskInfo;
@property (nonatomic, assign) int countOfExecuteSubTask;
@property (nonatomic, assign) int errCountOfSubTask;
@property (nonatomic, copy) Block_Void executeSubTask;
@property (nonatomic, assign) NBLHTTPFileTaskStatus taskStatus;
@property (nonatomic, copy) NBLHTTPFileProgress progress;
@property (nonatomic, copy) NBLHTTPFileResult result;
- (instancetype)init NS_UNAVAILABLE;
@end

#pragma mark Implementation NBLHTTPFileTaskOperation

@implementation NBLHTTPFileTaskOperation

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"yjh4866.NBLHTTPFileTaskOperation"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

- (instancetype)initWithFilePath:(NSString *)filePath andUrl:(NSString *)url
{
    self = [super init];
    if (self) {
        self.filePath = filePath;
        self.url = url;
        _taskStatus = NBLHTTPFileTaskStatus_Waiting;
        self.countOfExecuteSubTask = 0;
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"com.yjh4866.NBLHTTPFileTaskOperation.lock";
        
        __weak typeof(self) weakSelf = self;
        self.executeSubTask = ^() {
            [weakSelf.lock lock];
            // 一共下载两次，即下载失败可以再试一次
            if (weakSelf.countOfExecuteSubTask < 2) {
                // 启动线程以执行子任务
                [weakSelf performSelector:@selector(operationDidStart) onThread:[NBLHTTPFileTaskOperation networkRequestThread] withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
            }
            // 下载失败
            else {
                // 文件下载任务结束
                weakSelf.taskStatus = NBLHTTPFileTaskStatus_Finished;
                // GCD异步通过dispatch_get_main_queue回调
                __strong typeof(weakSelf) strongSelf = weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (strongSelf.result) {
                        NSError *error = [NSError errorWithDomain:@"NBLHTTPFileManager" code:NSURLErrorTimedOut userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"未下载完成"]}];
                        strongSelf.result(nil, strongSelf.httpResponse, error, strongSelf.param);
                    }
                });
            }
            [weakSelf.lock unlock];
        };
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)setTaskStatus:(NBLHTTPFileTaskStatus)taskStatus {
    [self.lock lock];
    NSString *oldStateKey = KeyPathFromHTTPFileTaskStatus(self.taskStatus);
    NSString *newStateKey = KeyPathFromHTTPFileTaskStatus(taskStatus);
    
    // 下面这四行KVO代码很重要，用以通知Operation任务状态变更
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _taskStatus = taskStatus;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    [self.lock unlock];
}

- (BOOL)isCancelled
{
    return NBLHTTPFileTaskStatus_Canceling == self.taskStatus;
}
- (BOOL)isExecuting
{
    return ((NBLHTTPFileTaskStatus_GetFileSize == self.taskStatus) ||
            (NBLHTTPFileTaskStatus_GetFileData == self.taskStatus));
}
- (BOOL)isFinished
{
    return NBLHTTPFileTaskStatus_Finished == self.taskStatus;
}

- (void)start
{
    [self.lock lock];
    [super start];
    BOOL needHeadRequest = YES;
    // 如果临时文件存在，则从中提取任务信息并添加到下载队列
    NSString *filePathTemp = FilePath_Temp(self.filePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathTemp]) {
        // 先获取实际文件大小（实际文件大小+配置数据+8字节的实际文件大小）
        int64_t fileSize = 0;
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePathTemp];
        int64_t tempFileSize = [fileHandle seekToEndOfFile];
        [fileHandle seekToFileOffset:tempFileSize-8];
        NSData *dataFileSize = [fileHandle readDataOfLength:8];
        [dataFileSize getBytes:&fileSize length:8];
        self.totalBytes = fileSize;
        // 再获取任务信息数据
        [fileHandle seekToFileOffset:fileSize];
        NSData *dataTaskInfo = [fileHandle readDataOfLength:(NSUInteger)(tempFileSize-fileSize-8)];
        [fileHandle closeFile];
        // 解析成字典，即为子任务字典
        self.mdicSubTaskInfo = [NSJSONSerialization JSONObjectWithData:dataTaskInfo options:NSJSONReadingMutableContainers error:nil];
        // 任务信息数据为字典
        if (self.mdicSubTaskInfo && [self.mdicSubTaskInfo isKindOfClass:NSDictionary.class]) {
            needHeadRequest = NO;
            // 计算当前进度
            self.bytesReceived = self.totalBytes;
            for (NSDictionary *dicSubTask in self.mdicSubTaskInfo.allValues) {
                self.bytesReceived -= [dicSubTask[@"Len"] intValue];
            }
            // 告知当前进度
            int64_t bytesReceived = self.bytesReceived;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.progress) {
                    self.progress(bytesReceived, self.totalBytes, self.param);
                }
            });
            // 执行子任务
            self.taskStatus = NBLHTTPFileTaskStatus_GetFileData;
            self.executeSubTask();
        }
        else {
            self.mdicSubTaskInfo = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePathTemp error:nil];
        }
    }
    // 先获取文件大小
    if (needHeadRequest) {
        self.taskStatus = NBLHTTPFileTaskStatus_GetFileSize;
        // 创建URLRequest
        NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        [mURLRequest setHTTPMethod:@"HEAD"];
        [mURLRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [mURLRequest setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
        // 获取文件大小
        __weak typeof(self) weakSelf = self;
        [[NBLHTTPManager sharedManagerForHTTPFileManger] requestObject:NBLResponseObjectType_Data withRequest:mURLRequest param:@{@"Type": @"HEAD", @"url": self.url} progress:nil andResult:^(NSHTTPURLResponse *httpResponse, id responseObject, NSError *error, NSDictionary *dicParam) {
            weakSelf.httpResponse = httpResponse;
            // 存在错误，或数据长度过短，则结束
            if (error || httpResponse.expectedContentLength < 1) {
                // 文件下载任务结束
                weakSelf.taskStatus = NBLHTTPFileTaskStatus_Finished;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.result) {
                        weakSelf.result(weakSelf.filePath, weakSelf.httpResponse, error, weakSelf.param);
                    }
                });
            }
            else {
                weakSelf.totalBytes = httpResponse.expectedContentLength;
                // 通过下载进度提示总大小
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (weakSelf.progress) {
                        weakSelf.progress(0, weakSelf.totalBytes, weakSelf.param);
                    }
                });
                // 生成子任务列表
                int64_t fileSize = weakSelf.httpResponse.expectedContentLength;
                const int sizePartFile = 256*1024;
                weakSelf.mdicSubTaskInfo = [NSMutableDictionary dictionary];
                unsigned int subTaskCount = ceilf(1.0f*fileSize/sizePartFile); // 每一个任务项大小
                unsigned int subTaskLen = ceilf(1.0f*fileSize/subTaskCount);
                for (int i = 0; i < subTaskCount-1; i++) {
                    [weakSelf.mdicSubTaskInfo setObject:[NSMutableDictionary dictionaryWithDictionary:@{@"Len": @(subTaskLen)}] forKey:[NSString stringWithFormat:@"%@", @(i*subTaskLen)]];
                }
                unsigned int startLast = (subTaskCount-1)*subTaskLen;
                [weakSelf.mdicSubTaskInfo setValue:[NSMutableDictionary dictionaryWithDictionary:@{@"Len": @(fileSize-startLast)}] forKey:[NSString stringWithFormat:@"%@", @(startLast)]];
                
                // 生成临时文件
                NSString *filePathTemp = FilePath_Temp(weakSelf.filePath);
                [[NSFileManager defaultManager] createFileAtPath:filePathTemp contents:nil attributes:nil];
                // 保存临时文件数据
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePathTemp];
                // 跳过实际文件数据区，保存任务信息
                [fileHandle seekToFileOffset:fileSize];
                NSData *dataTaskInfo = [NSJSONSerialization dataWithJSONObject:weakSelf.mdicSubTaskInfo options:NSJSONWritingPrettyPrinted error:nil];
                [fileHandle writeData:dataTaskInfo];
                // 保存文件大小
                [fileHandle seekToFileOffset:fileSize+dataTaskInfo.length];
                [fileHandle writeData:[NSData dataWithBytes:&fileSize length:8]];
                // 掐掉可能多余的数据
                [fileHandle truncateFileAtOffset:fileSize+dataTaskInfo.length+8];
                [fileHandle closeFile];
                
                // 执行子任务
                weakSelf.executeSubTask();
            }
        } onCompletionQueue:httpfile_operation_headcompletion_queue()];
    }
    [self.lock unlock];
}

- (void)operationDidStart {
    [self.lock lock];
    
    self.countOfExecuteSubTask += 1;
    self.errCountOfSubTask = 0;
    self.bytesReceived = self.totalBytes;
    // 遍历子任务并启动下载
    for (NSString *strKey in self.mdicSubTaskInfo.allKeys) {
        NSMutableDictionary *mdicSubTask = self.mdicSubTaskInfo[strKey];
        self.bytesReceived -= [mdicSubTask[@"Len"] intValue];
        // 创建URLRequest
        NSMutableURLRequest *mURLRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
        [mURLRequest setValue:[NSString stringWithFormat:@"bytes=%@-%@", strKey, @([strKey intValue]+[mdicSubTask[@"Len"] intValue]-1)] forHTTPHeaderField:@"RANGE"];
        [mURLRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [mURLRequest setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
        // 下载文件段
        __weak typeof(self) weakSelf = self;
        [[NBLHTTPManager sharedManagerForHTTPFileManger] requestObject:NBLResponseObjectType_Data withRequest:mURLRequest param:@{@"url": self.url, @"Start": strKey, @"Len": mdicSubTask[@"Len"]} progress:nil andResult:^(NSHTTPURLResponse *httpResponse, id responseObject, NSError *error, NSDictionary *dicParam) {
            [weakSelf.lock lock];
            // 下载成功
            if (nil == error) {
                // 将下载到的数据保存到临时文件
                NSString *filePathTemp = FilePath_Temp(weakSelf.filePath);
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePathTemp];
                [fileHandle seekToFileOffset:[strKey intValue]];
                [fileHandle writeData:responseObject];
                // 删除该子任务
                [weakSelf.mdicSubTaskInfo removeObjectForKey:dicParam[@"Start"]];
                // 还存在未完成的子任务，更新任务进度
                if (weakSelf.mdicSubTaskInfo.count > 0) {
                    weakSelf.bytesReceived += [dicParam[@"Len"] intValue];
                    // 将任务进度更新到文件
                    [fileHandle seekToFileOffset:weakSelf.totalBytes];
                    NSData *dataTaskInfo = [NSJSONSerialization dataWithJSONObject:weakSelf.mdicSubTaskInfo options:NSJSONWritingPrettyPrinted error:nil];
                    [fileHandle writeData:dataTaskInfo];
                    // 保存文件大小
                    [fileHandle seekToFileOffset:weakSelf.totalBytes+dataTaskInfo.length];
                    int64_t fileSize = weakSelf.totalBytes;
                    [fileHandle writeData:[NSData dataWithBytes:&fileSize length:8]];
                    // 掐掉可能多余的数据
                    [fileHandle truncateFileAtOffset:fileSize+dataTaskInfo.length+8];
                    [fileHandle closeFile];
                    // 文件下载进度变更
                    int64_t bytesReceived = weakSelf.bytesReceived;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.progress) {
                            weakSelf.progress(bytesReceived, weakSelf.totalBytes, weakSelf.param);
                        }
                    });
                    // 错误的子任务数量，与剩余子任务数量相同，则所有子任务均已完成，再次执行子任务
                    if (weakSelf.mdicSubTaskInfo.count == weakSelf.errCountOfSubTask) {
                        weakSelf.executeSubTask();
                    }
                }
                else {
                    // 掐掉下载进度相关数据
                    [fileHandle truncateFileAtOffset:weakSelf.totalBytes];
                    [fileHandle closeFile];
                    // 将临时文件修改为正式文件
                    [[NSFileManager defaultManager] removeItemAtPath:weakSelf.filePath error:nil];
                    [[NSFileManager defaultManager] moveItemAtPath:filePathTemp toPath:weakSelf.filePath error:nil];
                    // 文件下载任务结束
                    weakSelf.taskStatus = NBLHTTPFileTaskStatus_Finished;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.result) {
                            weakSelf.result(weakSelf.filePath, weakSelf.httpResponse, nil, weakSelf.param);
                        }
                    });
                }
            }
            // 下载失败
            else {
                weakSelf.errCountOfSubTask += 1;
                // 错误的子任务数量，与剩余子任务数量相同，则所有子任务均已完成
                if (weakSelf.mdicSubTaskInfo.count == weakSelf.errCountOfSubTask) {
                    weakSelf.executeSubTask();
                }
            }
            [weakSelf.lock unlock];
        } onCompletionQueue:httpfile_operation_completion_queue()];
    }
    [self.lock unlock];
}

@end

#endif


#pragma mark -
#pragma mark - NSURLSessionDownloadTask方案
#pragma mark -

static dispatch_queue_t urlsession_creation_queue() {
    static dispatch_queue_t urlsession_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        urlsession_creation_queue = dispatch_queue_create("com.yjh4866.urlsession.httpfile.creation.queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return urlsession_creation_queue;
}

static dispatch_group_t urlsession_completion_group() {
    static dispatch_group_t urlsession_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        urlsession_completion_group = dispatch_group_create();
    });
    
    return urlsession_completion_group;
}


#pragma mark URLSessionDownloadTaskItem

@interface URLSessionDownloadTaskItem : NSObject
@property (nonatomic, strong) NSURLSessionDownloadTask *urlSessionTask;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, copy) NBLHTTPFileProgress progress;
@property (nonatomic, copy) NBLHTTPFileResult result;
@property (nonatomic, strong) NSDictionary *param;
@end
@implementation URLSessionDownloadTaskItem
@end


#pragma mark - NBLHTTPFileManager

@interface NBLHTTPFileManager () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSURLSession *urlSession;
@property (readwrite, nonatomic, strong) NSMutableDictionary *mdicTaskItemForTaskIdentifier;
@property (readwrite, nonatomic, strong) NSLock *lock;
@end

#pragma mark Implementation NBLHTTPFileManager

@implementation NBLHTTPFileManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        // NSURLSession存在，即系统版本为7.0及以上，则采用NSURLSession来下载文件
        if (NSClassFromString(@"NSURLSession")) {
            self.operationQueue.maxConcurrentOperationCount = 1;
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            urlSessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
            self.urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:self.operationQueue];
            self.mdicTaskItemForTaskIdentifier = [[NSMutableDictionary alloc] init];
            self.lock = [[NSLock alloc] init];
            self.lock.name = @"com.yjh4866.NBLHTTPFileManager.lock";
        }
        
        self.lock = [[NSLock alloc] init];
        self.lock.name = @"com.yjh4866.NBLHTTPFileManager.lock";
    }
    return self;
}

- (void)dealloc
{
}

// 通用对象
+ (NBLHTTPFileManager *)sharedManager
{
    static NBLHTTPFileManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[NBLHTTPFileManager alloc] init];
    });
    return sharedManager;
}

// 指定url的下载任务是否存在
- (BOOL)downloadTaskIsExist:(NSString *)url
{
    if (self.urlSession) {
        [self.lock lock];
        // 先查一下是否已经存在
        for (__block URLSessionDownloadTaskItem *taskItem in self.mdicTaskItemForTaskIdentifier.allValues) {
            // 参数相等，且未取消未完成
            if ([taskItem.url isEqualToString:url] &&
                NSURLSessionTaskStateCanceling != taskItem.urlSessionTask.state &&
                NSURLSessionTaskStateCompleted != taskItem.urlSessionTask.state) {
                [self.lock unlock];
                return YES;
            }
        }
        [self.lock unlock];
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    else {
        // 先查一下下载任务是否已经存在
        for (NBLHTTPFileTaskOperation *operation in self.operationQueue.operations) {
            // 参数相等，且未取消未完成
            if ([operation.url isEqualToString:url] &&
                !operation.isCancelled && !operation.finished) {
                return YES;
            }
        }
    }
#endif
    return NO;
}

// 下载文件到指定路径
// url相同则认为是同一下载任务
- (BOOL)downloadFile:(NSString *)filePath from:(NSString *)url withParam:(NSDictionary *)dicParam
            progress:(NBLHTTPFileProgress)progress andResult:(NBLHTTPFileResult)result
{
    // 先判断url是否有效
    NSURL *URLFile = [NSURL URLWithString:url];
    if (nil == URLFile) {
        return NO;
    }
    // 任务已经存在则直接返回
    if ([self downloadTaskIsExist:url]) {
        return NO;
    }
    
    // 未给定文件保存路径，则生成一个路径
    if (nil == filePath) {
        filePath = FilePath(url);
    }
    if (self.urlSession) {
        // 创建NSURLSessionDataTask
        __block NSURLSessionDownloadTask *urlSessionTask = nil;
        dispatch_sync(urlsession_creation_queue(), ^{
            // 如果临时文件存在，则用该文件继续下载
            NSString *filePathTemp = FilePath_Temp(filePath);
            NSData *fileData = [NSData dataWithContentsOfFile:filePathTemp];
            if (fileData.length > 0) {
                urlSessionTask = [self.urlSession downloadTaskWithResumeData:fileData];
                // 删除临时文件
                [[NSFileManager defaultManager] removeItemAtPath:filePathTemp error:nil];
            }
            // 临时文件不存在，或者创建失败则重新创建一个任务
            if (nil == urlSessionTask) {
                urlSessionTask = [self.urlSession downloadTaskWithURL:URLFile];
            }
        });
        // 配备任务项以保存相关数据
        URLSessionDownloadTaskItem *taskItem = [[URLSessionDownloadTaskItem alloc] init];
        taskItem.urlSessionTask = urlSessionTask;
        taskItem.filePath = filePath;
        taskItem.url = url;
        taskItem.progress = progress;
        taskItem.result = result;
        taskItem.param = dicParam;
        [self.lock lock];
        self.mdicTaskItemForTaskIdentifier[@(urlSessionTask.taskIdentifier)] = taskItem;
        [self.lock unlock];
        // 启动网络连接
        [urlSessionTask resume];
        return YES;
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    else {
        // 创建Operation
        NBLHTTPFileTaskOperation *operation = [[NBLHTTPFileTaskOperation alloc] initWithFilePath:filePath andUrl:url];
        operation.progress = progress;
        operation.result = result;
        operation.param = dicParam;
        [self.operationQueue addOperation:operation];
        return YES;
    }
#endif
    return NO;
}

// 取消下载
- (void)cancelDownloadFileFrom:(NSString *)url
{
    if (nil == url) {
        return;
    }
    if (self.urlSession) {
        [self.lock lock];
        // 遍历任务队列
        for (URLSessionDownloadTaskItem *taskItem in self.mdicTaskItemForTaskIdentifier.allValues) {
            // 参数相等，且未完成，则取消该任务
            if ([taskItem.url isEqualToString:url] &&
                NSURLSessionTaskStateCompleted != taskItem.urlSessionTask.state) {
                // 取消下载
                [taskItem.urlSessionTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    // 保存到固定的临时目录以备续传
                    NSString *filePathTemp = FilePath_Temp(taskItem.filePath);
                    [resumeData writeToFile:filePathTemp atomically:YES];
                }];
            }
        }
        [self.lock unlock];
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    else {
        // 遍历任务队列
        for (NBLHTTPFileTaskOperation *operation in self.operationQueue.operations) {
            // 参数相等，且未完成，则取消该任务
            if ([operation.url isEqualToString:url] && !operation.finished) {
                [operation cancel];
            }
        }
    }
#endif
}


#pragma mark NSURLSessionDelegate

/* The last message a session receives.  A session will only become
 * invalid because of a systemic error or when it has been
 * explicitly invalidated, in which case the error parameter will be nil.
 */
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    [self.lock lock];
    // 所有请求均出错
    for (__block URLSessionDownloadTaskItem *taskItem in self.mdicTaskItemForTaskIdentifier.allValues) {
        dispatch_group_async(urlsession_completion_group(), dispatch_get_main_queue(), ^{
            if (taskItem.result) {
                taskItem.result(taskItem.filePath, taskItem.httpResponse, error, taskItem.param);
            }
        });
    }
    [self.mdicTaskItemForTaskIdentifier removeAllObjects];
    [self.lock unlock];
}

#pragma mark NSURLSessionTaskDelegate

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    [self.lock lock];
    __block URLSessionDownloadTaskItem *taskItem = self.mdicTaskItemForTaskIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];
    // 网络连接意外断开，则需要保存缓存数据以备续传
    if (error.userInfo[NSURLSessionDownloadTaskResumeData]) {
        // 保存到固定的临时目录以备续传
        NSString *filePathTemp = FilePath_Temp(taskItem.filePath);
        [error.userInfo[NSURLSessionDownloadTaskResumeData] writeToFile:filePathTemp atomically:YES];
    }
    // 取消不算下载失败
    if (NSURLErrorCancelled != error.code) {
        // 通知下载结果
        dispatch_group_async(urlsession_completion_group(), dispatch_get_main_queue(), ^{
            if (taskItem.result) {
                taskItem.result(taskItem.filePath, taskItem.httpResponse, error, taskItem.param);
            }
        });
    }
    [self.lock lock];
    [self.mdicTaskItemForTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}


#pragma mark NSURLSessionDownloadTaskDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    [self.lock lock];
    __block URLSessionDownloadTaskItem *taskItem = self.mdicTaskItemForTaskIdentifier[@(downloadTask.taskIdentifier)];
    [self.lock unlock];
    // 移到指定的目录
    NSURL *dstURL = [NSURL fileURLWithPath:taskItem.filePath];
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:dstURL error:nil];
}

- (void)URLSession:(__unused NSURLSession *)session
      downloadTask:(__unused NSURLSessionDownloadTask *)downloadTask
      didWriteData:(__unused int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    [self.lock lock];
    __block URLSessionDownloadTaskItem *taskItem = self.mdicTaskItemForTaskIdentifier[@(downloadTask.taskIdentifier)];
    [self.lock unlock];
    // 告知进度更新
    dispatch_group_async(urlsession_completion_group(), dispatch_get_main_queue(), ^{
        if (taskItem.progress) {
            taskItem.progress(totalBytesWritten, totalBytesExpectedToWrite, taskItem.param);
        }
    });
}

- (void)URLSession:(__unused NSURLSession *)session
      downloadTask:(__unused NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    [self.lock lock];
    __block URLSessionDownloadTaskItem *taskItem = self.mdicTaskItemForTaskIdentifier[@(downloadTask.taskIdentifier)];
    [self.lock unlock];
    // 告知进度更新
    dispatch_group_async(urlsession_completion_group(), dispatch_get_main_queue(), ^{
        if (taskItem.progress) {
            taskItem.progress(fileOffset, expectedTotalBytes, taskItem.param);
        }
    });
}

@end
