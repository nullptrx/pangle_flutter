// Copyright (c) 2021 nullptrX
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// 广告对象的生命周期状态
enum AdState {
  /// 初始状态，尚未开始加载
  idle,

  /// 正在加载中
  loading,

  /// 加载成功，可以展示
  loaded,

  /// 正在展示中
  showing,

  /// 加载或展示失败
  failed,

  /// 已销毁，不可再使用
  disposed,
}

/// 广告加载失败时抛出的异常
class AdLoadException implements Exception {
  /// native 错误码
  final int code;

  /// 错误描述
  final String? message;

  const AdLoadException({required this.code, this.message});

  @override
  String toString() => 'AdLoadException(code: $code, message: $message)';
}
