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

import 'banner/bannerview_android.dart';
import 'banner/bannerview_ios.dart';
import 'banner/platform_interface.dart';
import 'config.dart';
import 'config_android.dart';
import 'config_ios.dart';
import 'util.dart';

/// Optional callback invoked when a web view is first created. [controller] is
/// the [BannerViewController] for the created banner view.
typedef void BannerViewCreatedCallback(BannerViewController controller);

class BannerView extends StatefulWidget {
  const BannerView({
    Key? key,
    this.iOS,
    this.android,
    this.onBannerViewCreated,
    this.gestureRecognizers,
    this.onClick,
    this.onShow,
    this.onDislike,
    this.onError,
    this.onRenderSuccess,
    this.onRenderFail,
  }) : super(key: key);

  final IOSBannerConfig? iOS;
  final AndroidBannerConfig? android;

  /// If not null invoked once the banner view is created.
  final BannerViewCreatedCallback? onBannerViewCreated;

  /// Which gestures should be consumed by the banner view.
  ///
  /// It is possible for other gesture recognizers to be competing with the banner view on pointer
  /// events, e.g if the banner view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The banner view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the banner view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  static BannerViewPlatform? _platform;

  /// Sets a custom [BannerViewPlatform].
  ///
  /// This property can be set to use a custom platform implementation for BannerViews.
  ///
  /// Setting `platform` doesn't affect [BannerView]s that were already created.
  ///
  /// The default value is [AndroidBannerView] on Android and [CupertinoBannerView] on iOS.
  static set platform(BannerViewPlatform? platform) {
    _platform = platform;
  }

  /// The BannerView platform that's used by this BannerVIew.
  ///
  /// The default value is [AndroidBannerView] on Android and [CupertinoBannerView] on iOS.
  static BannerViewPlatform get platform {
    if (_platform == null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          _platform = AndroidBannerView();
          break;
        case TargetPlatform.iOS:
          _platform = CupertinoBannerView();
          break;
        default:
          throw UnsupportedError(
              "Trying to use the default bannerview implementation for $defaultTargetPlatform but there isn't a default one");
      }
    }
    return _platform!;
  }

  Config? get config {
    Config? config;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        config = android;
        break;
      case TargetPlatform.iOS:
        config = iOS;
        break;
      default:
        throw UnsupportedError(
            "Trying to use the default bannerview implementation for $defaultTargetPlatform but there isn't a default one");
    }
    return config;
  }

  @override
  _BannerViewState createState() => _BannerViewState();

  /// 广告被点击
  final VoidCallback? onClick;

  /// 广告展示
  final VoidCallback? onShow;

  /// 点击了关闭按钮（不喜欢）
  final PangleOptionCallback? onDislike;

  /// 获取广告失败
  final PangleMessageCallback? onError;

  /// 渲染广告成功
  final VoidCallback? onRenderSuccess;

  /// 渲染广告失败
  final PangleMessageCallback? onRenderFail;
}

class _BannerViewState extends State<BannerView>
    with AutomaticKeepAliveClientMixin {
  final Completer<BannerViewController> _controller =
      Completer<BannerViewController>();

  _PlatformCallbacksHandler? _platformCallbacksHandler;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BannerView.platform.build(
      context: context,
      creationParams: widget.config!.toJSON(),
      bannerViewPlatformCallbacksHandler: _platformCallbacksHandler!,
      onBannerViewPlatformCreated: _onWebViewPlatformCreated,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  @override
  void initState() {
    super.initState();
    _platformCallbacksHandler = _PlatformCallbacksHandler(widget);
  }

  @override
  void didUpdateWidget(BannerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.future.then((BannerViewController controller) {
      _platformCallbacksHandler!._widget = widget;
      controller._updateWidget(widget);
    });
  }

  void _onWebViewPlatformCreated(
    BannerViewPlatformController bannerViewPlatform,
  ) {
    final BannerViewController controller = BannerViewController._(
        widget, bannerViewPlatform, _platformCallbacksHandler);
    _controller.complete(controller);
    if (widget.onBannerViewCreated != null) {
      widget.onBannerViewCreated!(controller);
    }
  }
}

/// Controls a [BannerView].
///
/// A [BannerViewController] instance can be obtained by setting the [BannerView.onBannerViewCreated]
/// callback for a [BannerView] widget.
class BannerViewController {
  BannerViewController._(
    this._widget,
    this._bannerViewPlatformController,
    this._platformCallbacksHandler,
  );

  final BannerViewPlatformController _bannerViewPlatformController;

  // todo unused_field
  // ignore: unused_field
  final _PlatformCallbacksHandler? _platformCallbacksHandler;

  // todo unused_field
  // ignore: unused_field
  BannerView _widget;

  Future<void> _updateWidget(BannerView widget) async {
    _widget = widget;
  }

  /// 更新可点击区域，默认为空。
  ///
  /// 可点击区域表示Widget在屏幕任何位置可触发点击事件的区域
  /// 当bounds为空时，则认为可点击范围为全屏。
  /// 但是受[updateRestrictedBounds]影响，即当Touchable区域中如果包含Restricted区域，
  /// Restricted区域内的点击事件会屏蔽掉。
  Future<void> updateTouchableBounds(List<Rect> bounds) async {
    await _bannerViewPlatformController.updateTouchableBounds(bounds);
  }

  /// 更新不可点击区域
  ///
  /// 一般用于处理NativeView与PlatformView重叠时点击事件冲突的问题。
  Future<void> updateRestrictedBounds(List<Rect> bounds) async {
    await _bannerViewPlatformController.updateRestrictedBounds(bounds);
  }
}

class _PlatformCallbacksHandler implements BannerViewPlatformCallbacksHandler {
  _PlatformCallbacksHandler(this._widget);

  BannerView _widget;

  @override
  void onClick() {
    _widget.onClick?.call();
  }

  @override
  void onDislike(String option) {
    _widget.onDislike?.call(option);
  }

  @override
  void onError(int code, String message) {
    _widget.onError?.call(code, message);
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
