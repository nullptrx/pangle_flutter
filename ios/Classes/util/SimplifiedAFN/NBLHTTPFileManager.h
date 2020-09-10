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

#import <Foundation/Foundation.h>

// 将url转换为文件名
NSString *transferFileNameFromURL(NSString *url);

/**
 *  HTTP文件下载进度
 *
 *  @param bytesReceived 已接收到的数据长度
 *  @param totalBytes    数据总长度。-1表示长度未知
 *  @param dicParam      回传对象
 */
typedef void (^NBLHTTPFileProgress)(int64_t bytesReceived, int64_t totalBytes,
                                    NSDictionary *dicParam);
/**
 *  HTTP文件下载结果
 *
 *  @param filePath     文件保存路径
 *  @param httpResponse HTTP响应对象NSHTTPURLResponse
 *  @param error        发生的错误。nil表示成功
 *  @param dicParam     回传对象
 */
typedef void (^NBLHTTPFileResult)(NSString *filePath, NSHTTPURLResponse *httpResponse,
                                  NSError *error, NSDictionary *dicParam);


/* 保留[[NBLHTTPFileManager alloc] init]的实例化方案。
 可以使用默认的单例请求数据，也可以另外实例化以与默认的单例对象区分开
 */
@interface NBLHTTPFileManager : NSObject

// 通用对象
+ (NBLHTTPFileManager *)sharedManager;

// 指定url的下载任务是否存在
- (BOOL)downloadTaskIsExist:(NSString *)url;

// 下载文件到指定路径
// url相同则认为是同一下载任务
- (BOOL)downloadFile:(NSString *)filePath from:(NSString *)url withParam:(NSDictionary *)dicParam
            progress:(NBLHTTPFileProgress)progress andResult:(NBLHTTPFileResult)result;

// 取消下载
- (void)cancelDownloadFileFrom:(NSString *)url;

@end
