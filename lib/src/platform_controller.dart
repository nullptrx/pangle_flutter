/*
 * Copyright (c) 2021 nullptrX
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
import 'dart:ui' show Rect;

/// Interface for talking to the view's platform implementation.
///
/// An instance implementing this interface is passed to the `onXXXViewPlatformCreated` callback that is
/// passed to [XXXViewPlatformBuilder#onXXXViewPlatformCreated].
///
/// Platform implementations that live in a separate package should extend this class rather than
/// implement it as pangle_flutter does not consider newly added methods to be breaking changes.
/// Extending this class (using `extends`) ensures that the subclass will get the default
/// implementation, while platform implementations that `implements` this interface will be broken
/// by newly added [PlatformController] methods.
abstract class PlatformController {
  /// 添加可点击区域列表
  Future<void> addTouchableBounds(List<Rect> bounds);

  /// 清除可点击区域
  Future<void> clearTouchableBounds();
}

abstract class ViewController {
  final PlatformController _controller;

  const ViewController(this._controller);

  /// 为广告添加可点击区域集合（仅iOS）。
  ///
  /// 点击穿透问题已处理，此处为添加额外的可点击区域
  /// 如果广告区域上有悬浮按钮之类的控件，FlutterOverlayView会以屏宽和控件的高度来创建视图
  /// ，导致部分区域广告不可点击。
  /// 假设屏宽300，控件的Rect(0, 0, 100, 100), 此时FlutterOverlayView的Rect(0, 0,
  /// 300, 100), 即是Rect(100, 0, 300, 100) 此区域被影响导致广告不可点击。
  ///
  /// 当bounds为空时，默认为FlutterOverlayView覆盖区域广告不可点击。
  /// 当bounds不为空时，则优先于FlutterOverlayView覆盖区域判断是否可以点击。
  ///
  /// 重复添加相同区域，不影响整体
  Future<void> addTouchableBounds(List<Rect> bounds) async {
    await _controller.addTouchableBounds(bounds);
  }

  /// 添加可点击区域
  ///
  /// 见[addTouchableBounds]
  Future<void> addTouchableBound(Rect bound) async {
    await _controller.addTouchableBounds([bound]);
  }

  /// 清空可点击区域
  ///
  /// 见[addTouchableBounds]
  Future<void> clearTouchableBounds() async {
    await _controller.clearTouchableBounds();
  }
}
