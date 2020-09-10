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

#import <UIKit/UIKit.h>


// 图片下载结束后的block回调
// error只在图片下载失败时有效，表示下载失败时的错误
typedef void (^UIImageViewDownloadImageResult) (UIImageView *imageView, NSString *picUrl,
                                                float progress, BOOL finished, NSError *error);


@interface UIImageView (NBL)

/**
 *	@brief	清除UIImageView的缓存
 */
+ (void)clearCacheOfUIImageView;

/**
 *	@brief	获取UIImageView的缓存路径
 *
 *	@return	UIImageView默认的缓存路径
 */
+ (NSString *)cachePathOfUIImageView;

/**
 *    @brief    设置图片路径和网址（不全为空）
 *    @param     picUrl     图片下载地址
 */
- (void)loadImageFromUrl:(NSString *)picUrl;

/**
 *	@brief	设置图片路径和网址（不全为空）
 *
 *	@param 	filePath 	缓存图片保存路径
 *	@param 	picUrl 	图片下载地址
 */
- (void)loadImageFromCachePath:(NSString *)filePath orPicUrl:(NSString *)picUrl;

/**
 *	@brief	设置图片路径和网址（不全为空）
 *
 *	@param 	filePath 	缓存图片保存路径
 *	@param 	picUrl 	图片下载地址
 *	@param 	result 	图片下载结束后的block回调
 */
- (void)loadImageFromCachePath:(NSString *)filePath orPicUrl:(NSString *)picUrl
            withDownloadResult:(UIImageViewDownloadImageResult)downloadResult;

/**
 *	@brief	取消下载图片
 */
- (void)cancelDownload;

@end
