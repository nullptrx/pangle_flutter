/*
 * Copyright (c) 2022 nullptrX
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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../model.dart';
import '../pangle_plugin.dart';
import '../util.dart';
import 'feed/feedview_android.dart';
import 'feed/feedview_ios.dart';
import 'feed/platform_interface.dart';
import 'platform_controller.dart';

/// Optional callback invoked when a web view is first created. [controller] is
/// the [FeedViewController] for the created feed view.
typedef FeedViewCreatedCallback = void Function(FeedViewController controller);

class FeedView extends StatefulWidget {
  const FeedView({
    super.key,
    this.id,
    this.expressSize,
    this.onFeedViewCreated,
    this.gestureRecognizers,
    this.onClick,
    this.onShow,
    this.onDislike,
    this.onRenderSuccess,
    this.onRenderFail,
  });

  final String? id;

  /// 与 [loadFeedAd] 时传入的 [PangleExpressSize] 保持一致，
  /// FeedView 会自动按此比例约束自身尺寸（height > 0 时生效）。
  final PangleExpressSize? expressSize;

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
          _platform = const AndroidFeedView();
          break;
        case TargetPlatform.iOS:
          _platform = const CupertinoFeedView();
          break;
        default:
          throw UnsupportedError(
            "Trying to use the default feedview implementation for $defaultTargetPlatform but there isn't a default one",
          );
      }
    }
    return _platform!;
  }

  Map<String, dynamic> get config {
    return <String, dynamic>{'id': id, 'isUserInteractionEnabled': false};
  }

  @override
  FeedViewState createState() => FeedViewState();

  /// 广告被点击
  final VoidCallback? onClick;

  /// 广告展示
  final VoidCallback? onShow;

  /// 点击了关闭按钮（不喜欢）
  final PangleOptionCallback? onDislike;

  /// 渲染广告成功，参数为实际渲染尺寸（逻辑像素）。
  /// 使用优选模板（expressSize.height == 0）时可据此调整外部容器。
  final void Function(double width, double height)? onRenderSuccess;

  /// 渲染广告失败
  final PangleMessageCallback? onRenderFail;
}

class FeedViewState extends State<FeedView> with AutomaticKeepAliveClientMixin {
  _PlatformCallbacksHandler? _platformCallbacksHandler;
  // Actual rendered height received from onRenderSuccess when height == 0.
  double? _autoHeight;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final view = FeedView.platform.build(
      context: context,
      creationParams: widget.config,
      feedViewPlatformCallbacksHandler: _platformCallbacksHandler!,
      onFeedViewPlatformCreated: _onWebViewPlatformCreated,
      gestureRecognizers: widget.gestureRecognizers,
    );
    final size = widget.expressSize;
    if (size != null && size.height > 0) {
      return AspectRatio(aspectRatio: size.width / size.height, child: view);
    }
    if (size != null && size.height == 0) {
      return Center(
        child: SizedBox(
          width: size.width,
          height: _autoHeight ?? 1,
          child: view,
        ),
      );
    }
    return view;
  }

  @override
  void initState() {
    super.initState();
    _platformCallbacksHandler = _PlatformCallbacksHandler(widget);
    _platformCallbacksHandler!.onSizeChanged = (w, h) {
      if (mounted && widget.expressSize?.height == 0) {
        setState(() => _autoHeight = h);
      }
    };
  }

  @override
  void dispose() {
    final id = widget.id;
    if (id != null) pangle.removeFeedAd([id]);
    super.dispose();
  }

  @override
  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _platformCallbacksHandler!._widget = widget;
  }

  void _onWebViewPlatformCreated(FeedViewPlatformController feedViewPlatform) {
    final FeedViewController controller = FeedViewController._(
      feedViewPlatform,
    );
    if (widget.onFeedViewCreated != null) {
      widget.onFeedViewCreated!(controller);
    }
  }
}

/// Controls a [FeedView].
///
/// A [FeedViewController] instance can be obtained by setting the [FeedView.onFeedViewCreated]
/// callback for a [FeedView] widget.
class FeedViewController extends ViewController {
  FeedViewController._(FeedViewPlatformController super.controller);
}

class _PlatformCallbacksHandler implements FeedViewPlatformCallbacksHandler {
  _PlatformCallbacksHandler(this._widget);

  FeedView _widget;
  void Function(double width, double height)? onSizeChanged;

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
  void onRenderSuccess(double width, double height) {
    onSizeChanged?.call(width, height);
    _widget.onRenderSuccess?.call(width, height);
  }

  @override
  void onShow() {
    _widget.onShow?.call();
  }
}
