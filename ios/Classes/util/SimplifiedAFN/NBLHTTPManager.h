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

/**
 *  HTTP请求的响应类型
 */
typedef NS_ENUM(unsigned int, NBLResponseObjectType){
    /**
     *  NSData
     */
    NBLResponseObjectType_Data = 0,
    /**
     *  NSString
     */
    NBLResponseObjectType_String,
    /**
     *  JSON对象
     */
    NBLResponseObjectType_JSON
};

/**
 *  HTTP请求进度
 *
 *  @param webData       webData为nil表示收到响应
 *  @param bytesReceived 已接收到的数据长度
 *  @param totalBytes    数据总长度。-1表示长度未知
 *  @param dicParam      回传对象
 */
typedef void (^NBLHTTPProgress)(NSData *webData, int64_t bytesReceived,
                                int64_t totalBytes, NSDictionary *dicParam);
/**
 *  HTTP请求结果
 *
 *  @param httpResponse   HTTP响应对象NSHTTPURLResponse
 *  @param responseObject 请求到的对象，
 *  @param error          发生的错误。nil表示成功
 *  @param dicParam       回传对象
 */
typedef void (^NBLHTTPResult)(NSHTTPURLResponse *httpResponse, id responseObject,
                              NSError *error, NSDictionary *dicParam);


/* 保留[[NBLHTTPManager alloc] init]的实例化方案。
   可以使用默认的单例请求数据，也可以另外实例化以与默认的单例对象区分开
 */
@interface NBLHTTPManager : NSObject

// 通用单例
+ (NBLHTTPManager *)sharedManager;

// 指定参数的网络请求是否存在
- (BOOL)requestIsExist:(NSDictionary *)dicParam;

// 指定url的网络请求是否存在
- (BOOL)urlIsRequesting:(NSString *)url;

// 根据url获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType fromURL:(NSString *)url
            withParam:(NSDictionary *)dicParam andResult:(NBLHTTPResult)result;

// 根据NSURLRequest获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType
          withRequest:(NSURLRequest *)request param:(NSDictionary *)dicParam
            andResult:(NBLHTTPResult)result;

// 根据url获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType fromURL:(NSString *)url
            withParam:(NSDictionary *)dicParam
             progress:(NBLHTTPProgress)progress andResult:(NBLHTTPResult)result;

// 根据NSURLRequest获取Web数据（dicParam不为空则以此为去重依据，否则以url为去重依据）
// dicParam 可用于回传数据，需要取消时不可为nil
- (BOOL)requestObject:(NBLResponseObjectType)resObjType
          withRequest:(NSURLRequest *)request param:(NSDictionary *)dicParam
             progress:(NBLHTTPProgress)progress andResult:(NBLHTTPResult)result;

// 取消网络请求
- (void)cancelRequestWithParam:(NSDictionary *)dicParam;

@end
