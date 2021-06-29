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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'feed/feedview_android.dart';
import 'feed/feedview_ios.dart';
import 'feed/platform_interface.dart';
import 'util.dart';

/// Optional callback invoked when a web view is first created. [controller] is
/// the [FeedViewController] for the created feed view.
typedef void FeedViewCreatedCallback(FeedViewController controller);

class FeedView extends StatefulWidget {
  const FeedView({
    Key? key,
    this.id,
    this.onFeedViewCreated,
    this.gestureRecognizers,
    this.onClick,
    this.onShow,
    this.onDislike,
    this.onRenderSuccess,
    this.onRenderFail,
  }) : super(key: key);

  final String? id;

  /// If not null invoked once the feed view is created.
  final FeedViewCreatedCallback? onFeedViewCreated;

  /// Which gestures should be consumed by the feed view.
  ///
  /// It is possible for other gesture recognizers to be competing with the feed view on pointer
  /// events, e.g if the feed view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The feed view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the feed view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  static FeedViewPlatform? _platform;

  /// Sets a custom [FeedViewPlatform].
  ///
  /// This property can be set to use a custom platform implementation for FeedViews.
  ///
  /// Setting `platform` doesn't affect [FeedView]s that were already created.
  ///
  /// The default value is [AndroidFeedView] on Android and [CupertinoFeedView] on iOS.
  static set platform(FeedViewPlatform platform) {
    _platform = platform;
  }

  /// The FeedView platform that's used by this FeedVIew.
  ///
  /// The default value is [AndroidFeedView] on Android and [CupertinoFeedView] on iOS.
  static FeedViewPlatform get platform {
    if (_platform == null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          _platform = AndroidFeedView();
          break;
        case TargetPlatform.iOS:
          _platform = CupertinoFeedView();
          break;
        default:
          throw UnsupportedError(
              "Trying to use the default feedview implementation for $defaultTargetPlatform but there isn't a default one");
      }
    }
    return _platform!;
  }

  Map<String, dynamic> get config {
    return {
      'id': id,
      'isUserInteractionEnabled': false,
    };
  }

  @override
  _FeedViewState createState() => _FeedViewState();

  /// 广告被点击
  final VoidCallback? onClick;

  /// 广告展示
  final VoidCallback? onShow;

  /// 点击了关闭按钮（不喜欢）
  final PangleOptionCallback? onDislike;

  /// 渲染广告成功
  final VoidCallback? onRenderSuccess;

  /// 渲染广告失败
  final PangleMessageCallback? onRenderFail;
}

class _FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin {
  final Completer<FeedViewController> _controller =
      Completer<FeedViewController>();

  _PlatformCallbacksHandler? _platformCallbacksHandler;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FeedView.platform.build(
      context: context,
      creationParams: widget.config,
      feedViewPlatformCallbacksHandler: _platformCallbacksHandler!,
      onFeedViewPlatformCreated: _onWebViewPlatformCreated,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  @override
  void initState() {
    super.initState();
    _platformCallbacksHandler = _PlatformCallbacksHandler(widget);
  }

  @override
  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.future.then((FeedViewController controller) {
      _platformCallbacksHandler!._widget = widget;
      controller._updateWidget(widget);
    });
  }

  void _onWebViewPlatformCreated(
    FeedViewPlatformController feedViewPlatform,
  ) {
    final FeedViewController controller = FeedViewController._(
        widget, feedViewPlatform, _platformCallbacksHandler);
    _controller.complete(controller);
    if (widget.onFeedViewCreated != null) {
      widget.onFeedViewCreated!(controller);
    }
  }
}

/// Controls a [FeedView].
///
/// A [FeedViewController] instance can be obtained by setting the [FeedView.onFeedViewCreated]
/// callback for a [FeedView] widget.
class FeedViewController {
  FeedViewController._(
    this._widget,
    this._feedViewPlatformController,
    this._platformCallbacksHandler,
  );

  final FeedViewPlatformController _feedViewPlatformController;

  // todo unused_field
  // ignore: unused_field
  final _PlatformCallbacksHandler? _platformCallbacksHandler;

  // todo unused_field
  // ignore: unused_field
  FeedView _widget;

  Future<void> _updateWidget(FeedView widget) async {
    _widget = widget;
  }

  /// 更新可点击区域，默认为空。
  ///
  /// 可点击区域表示Widget在屏幕任何位置可触发点击事件的区域
  /// 当bounds为空时，则认为可点击范围为全屏。
  /// 但是受[updateRestrictedBounds]影响，即当Touchable区域中如果包含Restricted区域，
  /// Restricted区域内的点击事件会屏蔽掉。
  Future<void> updateTouchableBounds(List<Rect> bounds) async {
    await _feedViewPlatformController.updateTouchableBounds(bounds);
  }

  /// 更新不可点击区域
  ///
  /// 一般用于处理NativeView与PlatformView重叠时点击事件冲突的问题。
  Future<void> updateRestrictedBounds(List<Rect> bounds) async {
    await _feedViewPlatformController.updateRestrictedBounds(bounds);
  }
}

class _PlatformCallbacksHandler implements FeedViewPlatformCallbacksHandler {
  _PlatformCallbacksHandler(this._widget);

  FeedView _widget;

  @override
  void onClick() {
    _widget.onClick?.call();
  }

  @override
  void onDislike(String option, bool enforce) {
    _widget.onDislike?.call(option, enforce);
  }

  @override
  void onRenderFail(int code, String message) {
    _widget.onRenderFail?.call(code, message);
  }

  @override
  void onRenderSuccess() {
    _widget.onRenderSuccess?.call();
  }

  @override
  void onShow() {
    _widget.onShow?.call();
  }
}
