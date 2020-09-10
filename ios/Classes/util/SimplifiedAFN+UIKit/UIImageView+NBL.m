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

#import "UIImageView+NBL.h"
#import "NBLHTTPFileManager.h"


#pragma mark - UIImageViewObject

@interface UIImageViewTask : NSObject
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, copy) UIImageViewDownloadImageResult downloadResult;
@end
@implementation UIImageViewTask
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"imageView" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"imageView"];
}
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    if ([keyPath isEqualToString:@"imageView"]) {
        UIImageView *imageViewNew = change[NSKeyValueChangeNewKey];
        UIImageView *imageViewOld = change[NSKeyValueChangeOldKey];
        // weak修饰的imageView释放导致该属性为nil，该KVO未监视到，原因未知
        // 所以只能通过外部调用cancelDownload的方式取消
        if (![imageViewNew isKindOfClass:UIImageView.class] &&
            [imageViewOld isKindOfClass:UIImageView.class]) {
            [imageViewOld cancelDownload];
        }
    }
}
@end

#pragma mark - UIImageViewManager

@interface UIImageViewManager : NSObject {
    NSMutableDictionary *_mdicURLKey;
}
@end

@implementation UIImageViewManager

- (id)init
{
    self = [super init];
    if (self) {
        _mdicURLKey = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (UIImageViewManager *)sharedInstance
{
    static dispatch_once_t onceToken;
    static UIImageViewManager *sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[UIImageViewManager alloc] init];
    });
    
    return sSharedInstance;
}

- (void)downloadFile:(NSString *)filePath from:(NSString *)url showOn:(UIImageView *)imageView
          withResult:(UIImageViewDownloadImageResult)downloadResult
{
    // 取出url相应的任务项
    NSMutableDictionary *mdicURLItem = _mdicURLKey[url];
    if (nil == mdicURLItem) {
        mdicURLItem = [NSMutableDictionary dictionary];
        _mdicURLKey[url] = mdicURLItem;
    }
    // 从任务项中取出任务列表
    NSMutableArray *marrItem = mdicURLItem[@"list"];
    if (nil == marrItem) {
        marrItem = [NSMutableArray array];
        mdicURLItem[@"list"] = marrItem;
    }
    // 加入下载任务
    UIImageViewTask *downloadTask = [[UIImageViewTask alloc] init];
    downloadTask.imageView = imageView;
    downloadTask.filePath = filePath;
    downloadTask.downloadResult = downloadResult;
    [marrItem addObject:downloadTask];
    // 第一次请求该url时才会下载
    if (marrItem.count == 1) {
        [[NBLHTTPFileManager sharedManager] downloadFile:filePath from:url withParam:@{@"url": url} progress:^(int64_t bytesReceived, int64_t totalBytes, NSDictionary *dicParam) {
            // 找到当前url对应的所有任务项
            NSString *url = dicParam[@"url"];
            NSArray *arrItem = _mdicURLKey[url][@"list"];
            // 遍历该任务项列表
            for (UIImageViewTask *downloadTask in arrItem) {
                // 开始下载的回调
                if (downloadTask.downloadResult) {
                    downloadTask.downloadResult(downloadTask.imageView, url, 1.0f*bytesReceived/totalBytes, NO, nil);
                }
            }
        } andResult:^(NSString *filePath, NSHTTPURLResponse *httpResponse, NSError *error, NSDictionary *dicParam) {
            // 找到当前url对应的所有任务项
            NSString *url = dicParam[@"url"];
            NSArray *arrItem = _mdicURLKey[url][@"list"];
            // 加载下载到的图片
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            if (image) {
                // 遍历该任务项列表
                for (UIImageViewTask *downloadTask in arrItem) {
                    // 设置图片
                    downloadTask.imageView.image = image;
                    // 开始下载的回调
                    if (downloadTask.downloadResult) {
                        downloadTask.downloadResult(downloadTask.imageView, url, 1.0f, YES, nil);
                    }
                }
            }
            else {
                NSError *error = [NSError errorWithDomain:@"NBLError" code:NSURLErrorCannotDecodeContentData userInfo:@{NSLocalizedDescriptionKey: @"图片数据错误"}];
                // 遍历该任务项列表
                for (UIImageViewTask *downloadTask in arrItem) {
                    // 开始下载的回调
                    if (downloadTask.downloadResult) {
                        downloadTask.downloadResult(downloadTask.imageView, url, 1.0f, YES, error);
                    }
                }
            }
            [_mdicURLKey removeObjectForKey:url];
        }];
    }
}

- (void)cancelDownload:(UIImageView *)imageView
{
    NSArray *arrKey = [_mdicURLKey allKeys];
    // 遍历所有url
    for (NSString *strKey in arrKey) {
        NSMutableDictionary *mdicURLItem = _mdicURLKey[strKey];
        NSMutableArray *marrItem = mdicURLItem[@"list"];
        // 遍历任务列表
        for (int i = 0; i < marrItem.count; i++) {
            UIImageViewTask *downloadTask = marrItem[i];
            // 找到需要取消的UIImageView
            if (downloadTask.imageView == imageView) {
                [marrItem removeObjectAtIndex:i];
                // 只有这一个下载则要取消下载任务
                if (0 == marrItem.count) {
                    [[NBLHTTPFileManager sharedManager] cancelDownloadFileFrom:strKey];
                    [_mdicURLKey removeObjectForKey:strKey];
                }
                break;
            }
        }
    }
}

@end


#pragma mark - UIImageView (NBL)

#define CachePath_UIImageView [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"UIImageView"]

@implementation UIImageView (NBL)

/**
 *	@brief	清除UIImageView的缓存
 */
+ (void)clearCacheOfUIImageView
{
    NSString *cachePath = CachePath_UIImageView;
    // 删除缓存目录下的所有文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager subpathsAtPath:cachePath];
    for (NSString *fileName in array) {
        [fileManager removeItemAtPath:[cachePath stringByAppendingPathComponent:fileName] error:nil];
    }
}

/**
 *	@brief	获取UIImageView的缓存路径
 *
 *	@return	UIImageView默认的缓存路径
 */
+ (NSString *)cachePathOfUIImageView
{
    return CachePath_UIImageView;
}

/**
 *    @brief    设置图片路径和网址（不全为空）
 *
 *    @param     picUrl     图片下载地址
 */
- (void)loadImageFromUrl: (NSString *)picUrl
{
    [self loadImageFromCachePath:nil orPicUrl:picUrl withDownloadResult:nil];
}

/**
 *	@brief	设置图片路径和网址（不全为空）
 *
 *	@param 	filePath 	缓存图片保存路径
 *	@param 	picUrl 	图片下载地址
 */
- (void)loadImageFromCachePath:(NSString *)filePath orPicUrl:(NSString *)picUrl
{
    [self loadImageFromCachePath:filePath orPicUrl:picUrl withDownloadResult:nil];
}

/**
 *	@brief	设置图片路径和网址（不全为空）
 *
 *	@param 	filePath 	缓存图片保存路径
 *	@param 	picUrl 	图片下载地址
 *	@param 	result 	图片下载结束后的block回调
 */
- (void)loadImageFromCachePath:(NSString *)filePath orPicUrl:(NSString *)picUrl
            withDownloadResult:(UIImageViewDownloadImageResult)downloadResult
{
    self.image = nil;
    // 无路径则使用默认路径
    if (filePath.length == 0) {
        NSString *cachePath = CachePath_UIImageView;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:cachePath]) {
            [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES
                                    attributes:nil error:nil];
        }
        NSString *fileName = transferFileNameFromURL(picUrl);
        filePath = [cachePath stringByAppendingPathComponent:fileName];
    }
    // 读缓存图片
    UIImage *imageCache = [UIImage imageWithContentsOfFile:filePath];
    // 读取缓存成功
    if (imageCache) {
        self.image = imageCache;
    }
    // 缓存图片没读取到，且url存在，则下载
    else if ([picUrl isKindOfClass:NSString.class] && picUrl.length > 0) {
        [[UIImageViewManager sharedInstance] downloadFile:filePath from:picUrl showOn:self
                                               withResult:downloadResult];
    }
}

/**
 *	@brief	取消下载图片
 */
- (void)cancelDownload
{
    [[UIImageViewManager sharedInstance] cancelDownload:self];
}

@end
