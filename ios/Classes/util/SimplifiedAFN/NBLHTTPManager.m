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

#import "NBLHTTPManager.h"


#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0

#pragma mark -
#pragma mark - NSURLConnection方案
#pragma mark -

static dispatch_group_t urlconnection_operation_completion_group() {
    static dispatch_group_t urlconnection_operation_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        urlconnection_operation_completion_group = dispatch_group_create();
    });
    return urlconnection_operation_completion_group;
}

static dispatch_queue_t urlconnection_operation_completion_queue() {
    static dispatch_queue_t urlconnection_operation_completion_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        urlconnection_operation_completion_queue = dispatch_queue_create("com.yjh4866.urlconnection.completion.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return urlconnection_operation_completion_queue;
}

static dispatch_group_t http_request_operation_completion_group() {
    static dispatch_group_t http_request_operation_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        http_request_operation_completion_group = dispatch_group_create();
    });
    return http_request_operation_completion_group;
}

static dispatch_queue_t http_request_operation_processing_queue() {
    static dispatch_queue_t http_request_operation_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        http_request_operation_processing_queue = dispatch_queue_create("com.yjh4866.http_request.processing.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return http_request_operation_processing_queue;
}

typedef NS_ENUM(unsigned int, URLConnectionStatus) {
    URLConnectionStatus_Canceling = 1,
    URLConnectionStatus_Waiting,
    URLConnectionStatus_Running,
    URLConnectionStatus_Finished,
};

static inline NSString * KeyPathFromHTTPTaskStatus(URLConnectionStatus state) {
    switch (state) {
        case URLConnectionStatus_Canceling:
            return @"isCanceling";
        case URLConnectionStatus_Waiting:
            return @"isWaiting";
        case URLConnectionStatus_Running:
            return @"isRunning";
        case URLConnectionStatus_Finished:
            return @"isFinished";
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            return @"state";
#pragma clang diagnostic pop
        }
    }
}


#pragma mark - URLConnectionOperation

@interface URLConnectionOperation : NSOperation <NSURLConnectionDataDelegate>
@property (nonatomic, assign) NBLResponseObjectType responseObjectType;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (readwrite, nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, strong) NSMutableData *mdataCache;
@property (nonatomic, copy) NBLHTTPProgress progress;
@property (readwrite, nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSDictionary *param;
@property (readwrite, nonatomic, assign) URLConnectionStatus taskStatus;

@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;

- (instancetype)init NS_UNAVAILABLE;
@end


#pragma mark - Implementation URLConnectionOperation

@implementation URLConnectionOperation

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"yjh4866.URLConnectionOperation"];
        
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

- (instancetype)initWithURLRequest:(NSURLRequest *)urlRequest
{
    self = [super init];
    if (self) {
        self.mdataCache = [[NSMutableData alloc] init];
        self.request = urlRequest;
        _taskStatus = URLConnectionStatus_Waiting;
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = @"com.yjh4866.URLConnectionOperation.lock";
    }
    return self;
}

- (void)dealloc
{
}

- (void)setTaskStatus:(URLConnectionStatus)taskStatus {
    [self.lock lock];
    NSString *oldStateKey = KeyPathFromHTTPTaskStatus(self.taskStatus);
    NSString *newStateKey = KeyPathFromHTTPTaskStatus(taskStatus);
    
    // 下面这四行KVO代码很重要，用以通知Operation任务状态变更
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _taskStatus = taskStatus;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    [self.lock unlock];
}

- (int64_t)totalBytes
{
    return self.httpResponse.expectedContentLength;
}

#pragma mark NSOperation

// 这里是为了让该NSOperation能正常释放，不然会在setHTTPResult:中的block循环引用
- (void)setCompletionBlock:(void (^)(void))block {
    [self.lock lock];
    if (!block) {
        [super setCompletionBlock:nil];
    } else {
        __weak typeof(self) weakSelf = self;
        [super setCompletionBlock:^ {
            
            dispatch_group_t group = urlconnection_operation_completion_group();
            
            dispatch_group_async(group, dispatch_get_main_queue(), ^{
                block();
            });
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_group_notify(group, urlconnection_operation_completion_queue(), ^{
                [strongSelf setCompletionBlock:nil];
            });
        }];
    }
    [self.lock unlock];
}

- (BOOL)isCancelled
{
    return URLConnectionStatus_Canceling == self.taskStatus;
}
- (BOOL)isExecuting
{
    return URLConnectionStatus_Running == self.taskStatus;
}
- (BOOL)isFinished
{
    return URLConnectionStatus_Finished == self.taskStatus;
}

- (void)start
{
    [self.lock lock];
    [super start];
    self.taskStatus = URLConnectionStatus_Running;
    [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:@[NSRunLoopCommonModes]];
    [self.lock unlock];
}

- (void)operationDidStart {
    [self.lock lock];
    // 用NSURLConnection创建网络连接
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
    // 启动网络连接
    [self.urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [self.urlConnection start];
    [self.lock unlock];
}

- (void)cancel
{
    [self.lock lock];
    [super cancel];
    self.taskStatus = URLConnectionStatus_Canceling;
    [self.urlConnection cancel];
    [self.lock unlock];
}

- (void)setHTTPResult:(NBLHTTPResult)result
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wgnu"
    self.completionBlock = ^{
        dispatch_async(http_request_operation_processing_queue(), ^{
            if (result) {
                dispatch_group_async(http_request_operation_completion_group(), self.completionQueue?:dispatch_get_main_queue(), ^{
                    if (nil != self.error) {
                        // 将已有数据保存到Error的userInfo中
                        NSMutableDictionary *mdicUserInfo = [NSMutableDictionary dictionary];
                        if (self.error.userInfo) {
                            [mdicUserInfo setDictionary:self.error.userInfo];
                        }
                        [mdicUserInfo setObject:self.mdataCache forKey:@"data"];
                        // 失败
                        NSError *err = [NSError errorWithDomain:self.error.domain code:self.error.code
                                                       userInfo:mdicUserInfo];
                        result(self.httpResponse, nil, err, self.param);
                    }
                    else if (NBLResponseObjectType_String == self.responseObjectType) {
                        NSString *strWebData = [[NSString alloc] initWithData:self.mdataCache
                                                                     encoding:NSUTF8StringEncoding];
                        if (strWebData) {
                            result(self.httpResponse, strWebData, nil, self.param);
                        }
                        else {
                            // 解析失败
                            NSError *err = [NSError errorWithDomain:@"NBLErrorDomain"
                                                               code:NSURLErrorCannotDecodeContentData
                                                           userInfo:@{@"data": self.mdataCache}];
                            result(self.httpResponse, nil, err, self.param);
                        }
                    }
                    else if (NBLResponseObjectType_JSON == self.responseObjectType) {
                        id responseObject = [NSJSONSerialization JSONObjectWithData:self.mdataCache options:NSJSONReadingAllowFragments error:nil];
                        if (responseObject) {
                            result(self.httpResponse, responseObject, nil, self.param);
                        }
                        else {
                            // 解析失败
                            NSError *err = [NSError errorWithDomain:@"NBLErrorDomain"
                                                               code:NSURLErrorCannotDecodeContentData
                                                           userInfo:@{@"data": self.mdataCache}];
                            result(self.httpResponse, nil, err, self.param);
                        }
                    }
                    else {
                        result(self.httpResponse, self.mdataCache, nil, self.param);
                    }
                });
            }
        });
    };
#pragma clang diagnostic pop
}


#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.lock lock];
    self.error = error;
    self.urlConnection = nil;
    self.taskStatus = URLConnectionStatus_Finished;
    [self.lock unlock];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.httpResponse = nil;
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        self.httpResponse = (NSHTTPURLResponse *)response;
    }
    // 通过下载进度提示总大小
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progress) {
            self.progress(nil, 0, self.totalBytes, self.param);
        }
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 追加数据
    [self.lock lock];
    [self.mdataCache appendData:data];
    [self.lock unlock];
    // 下载进度更新
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progress) {
            self.progress(data, self.mdataCache.length, self.totalBytes, self.param);
        }
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.lock lock];
    self.urlConnection = nil;
    self.taskStatus = URLConnectionStatus_Finished;
    [self.lock unlock];
}

@end

#endif


#pragma mark -
#pragma mark - NSURLSessionDataTask方案
#pragma mark -

static dispatch_queue_t urlsession_creation_queue() {
    static dispatch_queue_t urlsession_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        urlsession_creation_queue = dispatch_queue_create("com.yjh4866.urlsession.http.creation.queue", DISPATCH_QUEUE_SERIAL);
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


#pragma mark URLSessionTaskItem

@interface URLSessionTaskItem : NSObject
@property (nonatomic, assign) NBLResponseObjectType responseObjectType;
@property (nonatomic, strong) NSURLSessionDataTask *urlSessionTask;
@property (readwrite, nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, strong) NSMutableData *mdataCache;
@property (nonatomic, copy) NBLHTTPProgress progress;
@property (nonatomic, copy) NBLHTTPResult result;
@property (nonatomic, strong) NSDictionary *param;

@property (nonatomic, strong, nullable) dispatch_queue_t completionQueue;
@end


#pragma mark Implementation URLSessionTaskItem

@implementation URLSessionTaskItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mdataCache = [[NSMutableData alloc] init];
    }
    return self;
}
- (void)dealloc
{
    
}
- (int64_t)totalBytes
{
    return self.httpResponse.expectedContentLength;
}
@end


#pragma mark - NBLHTTPManager ()

@interface NBLHTTPManager () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, strong) NSURLSession *urlSession;
@property (readwrite, nonatomic, strong) NSMutableDictionary *mdicTaskItemForTaskIdentifier;
@property (readwrite, nonatomic, strong) NSLock *lock;
@end


#pragma mark - Implementation NBLHTTPManager

@implementation NBLHTTPManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        // NSURLSession存在，即系统版本为7.0及以上，则采用NSURLSession来发网络请求
        if (NSClassFromString(@"NSURLSession")) {
            self.operationQueue.maxConcurrentOperationCount = 1;
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            urlSessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
            self.urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfig delegate:self delegateQueue:self.operationQueue];
            self.mdicTaskItemForTaskIdentifier = [[NSMutableDictionary alloc] init];
            self.lock = [[NSLock alloc] init];
            self.lock.name = @"com.yjh4866.NBLHTTPManager.lock";
        }
    }
    return self;
}

- (void)dealloc
{
}

// 通用单例
+ (NBLHTTPManager *)sharedManager
{
    static NBLHTTPManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[NBLHTTPManager alloc] init];
    });
    return sharedManager;
}

// 指定参数的网络请求是否存在
- (BOOL)requestIsExist:(NSDictionary *)dicParam
{
    if (self.urlSession) {
        [self.lock lock];
        // 先查一下是否已经存在
        for (URLSessionTaskItem *taskItem in self.mdicTaskItemForTaskIdentifier.allValues) {
            // 参数相等，且未取消未完成
            if ([taskItem.param isEqualToDictionary:dicParam] &&
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
        // 先查一下是否已经存在
        for (URLConnectionOperation *operation in self.operationQueue.operations) {
            // 参数相等，且未取消未完成
            if ([operation.param isEqualToDictionary:dicParam] &&
                !operation.isCancelled && !operation.finished) {
                return YES;
            }
        }
    }
#endif
    return NO;
}

// 指定url的网络请求是否存在
- (BOOL)urlIsRequesting:(NSString *)url
{
    if (self.urlSession) {
        [self.lock lock];
        // 先查一下是否已经存在
        for (URLSessionTaskItem *taskItem in self.mdicTaskItemForTaskIdentifier.allValues) {
            // 参数相等，且未取消未完成
            if ([taskItem.request.URL.absoluteString isEqualToString:url] &&
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
        // 先查一下是否已经存在
        for (URLConnectionOperation *operation in self.operationQueue.operations) {
            // 参数相等，且未取消未完成
            if ([operation.request.URL.absoluteString isEqualToString:url] &&
                !operation.isCancelled && !operation.finished) {
                return YES;
            }
        }
    }
#endif
    return NO;
}

// 根据url获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType fromURL:(NSString *)url
            withParam:(NSDictionary *)dicParam andResult:(NBLHTTPResult)result
{
    return [self requestObject:resObjType fromURL:url withParam:dicParam
                      progress:nil andResult:result];
}

// 根据NSURLRequest获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType
          withRequest:(NSURLRequest *)request param:(NSDictionary *)dicParam
            andResult:(NBLHTTPResult)result
{
    return [self requestObject:resObjType withRequest:request param:dicParam
                      progress:nil andResult:result];
}

// 根据url获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType fromURL:(NSString *)url
            withParam:(NSDictionary *)dicParam
             progress:(NBLHTTPProgress)progress andResult:(NBLHTTPResult)result
{
    // 先判断url是否有效
    NSURL *URL = [NSURL URLWithString:url];
    if (nil == URL) {
        return NO;
    }
    // 实例化NSURLRequest
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:URL];
    // 开始请求数据
    return [self requestObject:resObjType withRequest:urlRequest param:dicParam
                      progress:progress andResult:result];
}

// 根据NSURLRequest获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType
          withRequest:(NSURLRequest *)request param:(NSDictionary *)dicParam
             progress:(NBLHTTPProgress)progress andResult:(NBLHTTPResult)result
{
    return [self requestObject:resObjType withRequest:request param:dicParam
                      progress:progress andResult:result onCompletionQueue:nil];
}

// 根据NSURLRequest获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType
          withRequest:(NSURLRequest *)request param:(NSDictionary *)dicParam
             progress:(NBLHTTPProgress)progress andResult:(NBLHTTPResult)result
    onCompletionQueue:(dispatch_queue_t)completionQueue
{
    // 任务已经存在则直接返回
    // dicParam存在则以此为判断依据
    if (nil != dicParam && [self requestIsExist:dicParam]) {
        return NO;
    }
    // dicParam不存在则以url为判断依据
    if (nil == dicParam && [self urlIsRequesting:request.URL.absoluteString]) {
        return NO;
    }
    
    if (self.urlSession) {
        // 创建NSURLSessionDataTask
        __block NSURLSessionDataTask *urlSessionTask = nil;
        dispatch_sync(urlsession_creation_queue(), ^{
            urlSessionTask = [self.urlSession dataTaskWithRequest:request];
        });
        // 配备任务项以保存相关数据
        URLSessionTaskItem *taskItem = [[URLSessionTaskItem alloc] init];
        taskItem.responseObjectType = resObjType;
        taskItem.urlSessionTask = urlSessionTask;
        taskItem.progress = progress;
        taskItem.result = result;
        taskItem.param = dicParam;
        taskItem.completionQueue = completionQueue;
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
        URLConnectionOperation *operation = [[URLConnectionOperation alloc] initWithURLRequest:request];
        operation.responseObjectType = resObjType;
        operation.progress = progress;
        operation.param = dicParam;
        operation.completionQueue = completionQueue;
        [operation setHTTPResult:result];
        [self.operationQueue addOperation:operation];
        return YES;
    }
#endif
    return NO;
}

// 取消网络请求
- (void)cancelRequestWithParam:(NSDictionary *)dicParam
{
    if (nil == dicParam) {
        return;
    }
    if (self.urlSession) {
        [self.lock lock];
        // 遍历任务队列
        for (URLSessionTaskItem *taskItem in self.mdicTaskItemForTaskIdentifier.allValues) {
            // 参数相等，且未完成，则取消该任务
            if ([taskItem.param isEqualToDictionary:dicParam] &&
                NSURLSessionTaskStateCompleted != taskItem.urlSessionTask.state) {
                [taskItem.urlSessionTask cancel];
            }
        }
        [self.lock unlock];
    }
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    else {
        // 遍历任务队列
        for (URLConnectionOperation *operation in self.operationQueue.operations) {
            // 参数相等，且未完成，则取消该任务
            if ([operation.param isEqualToDictionary:dicParam] && !operation.finished) {
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
    for (__block URLSessionTaskItem *taskItem in self.mdicTaskItemForTaskIdentifier.allValues) {
        dispatch_group_async(urlsession_completion_group(), taskItem.completionQueue?:dispatch_get_main_queue(), ^{
            if (taskItem.result) {
                taskItem.result(taskItem.httpResponse, taskItem.mdataCache, error, taskItem.param);
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
    __block URLSessionTaskItem *taskItem = self.mdicTaskItemForTaskIdentifier[@(task.taskIdentifier)];
    [self.lock unlock];
    // 取消不算失败
    if (NSURLErrorCancelled != error.code) {
        // 通知网络请求结果
        dispatch_group_async(urlsession_completion_group(), taskItem.completionQueue?:dispatch_get_main_queue(), ^{
            if (taskItem.result) {
                if (nil != error) {
                    // 将已有数据保存到Error的userInfo中
                    NSMutableDictionary *mdicUserInfo = [NSMutableDictionary dictionary];
                    if (error.userInfo) {
                        [mdicUserInfo setDictionary:error.userInfo];
                    }
                    [mdicUserInfo setObject:taskItem.mdataCache forKey:@"data"];
                    // 失败
                    NSError *err = [NSError errorWithDomain:error.domain code:error.code userInfo:mdicUserInfo];
                    taskItem.result(taskItem.httpResponse, nil, err, taskItem.param);
                }
                else if (NBLResponseObjectType_String == taskItem.responseObjectType) {
                    NSString *strWebData = [[NSString alloc] initWithData:taskItem.mdataCache
                                                                 encoding:NSUTF8StringEncoding];
                    if (strWebData) {
                        taskItem.result(taskItem.httpResponse, strWebData, nil, taskItem.param);
                    }
                    else {
                        // 解析失败
                        NSError *err = [NSError errorWithDomain:@"NBLErrorDomain"
                                                           code:NSURLErrorCannotDecodeContentData
                                                       userInfo:@{@"data": taskItem.mdataCache}];
                        taskItem.result(taskItem.httpResponse, nil, err, taskItem.param);
                    }
                }
                else if (NBLResponseObjectType_JSON == taskItem.responseObjectType) {
                    id responseObject = [NSJSONSerialization JSONObjectWithData:taskItem.mdataCache options:NSJSONReadingAllowFragments error:nil];
                    if (responseObject) {
                        taskItem.result(taskItem.httpResponse, responseObject, nil, taskItem.param);
                    }
                    else {
                        // 解析失败
                        NSError *err = [NSError errorWithDomain:@"NBLErrorDomain"
                                                           code:NSURLErrorCannotDecodeContentData
                                                       userInfo:@{@"data": taskItem.mdataCache}];
                        taskItem.result(taskItem.httpResponse, nil, err, taskItem.param);
                    }
                }
                else {
                    taskItem.result(taskItem.httpResponse, taskItem.mdataCache, nil, taskItem.param);
                }
            }
        });
    }
    [self.lock lock];
    [self.mdicTaskItemForTaskIdentifier removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}


#pragma mark NSURLSessionDataDelegate

// The task has received a response
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    [self.lock lock];
    __block URLSessionTaskItem *taskItem = self.mdicTaskItemForTaskIdentifier[@(dataTask.taskIdentifier)];
    [self.lock unlock];
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        taskItem.httpResponse = (NSHTTPURLResponse *)response;
    }
    // 通过下载进度提示总大小
    dispatch_group_async(urlsession_completion_group(), dispatch_get_main_queue(), ^{
        if (taskItem.progress) {
            taskItem.progress(nil, 0, taskItem.totalBytes, taskItem.param);
        }
    });
    
    if (completionHandler) {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [self.lock lock];
    __block URLSessionTaskItem *taskItem = self.mdicTaskItemForTaskIdentifier[@(dataTask.taskIdentifier)];
    [self.lock unlock];
    // 追加数据
    [taskItem.mdataCache appendData:data];
    // 下载进度更新
    dispatch_group_async(urlsession_completion_group(), dispatch_get_main_queue(), ^{
        if (taskItem.progress) {
            taskItem.progress(data, taskItem.mdataCache.length, taskItem.totalBytes, taskItem.param);
        }
    });
}

@end
