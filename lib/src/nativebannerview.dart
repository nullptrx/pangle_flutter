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

import 'native/bannerview_android.dart';
import 'native/bannerview_ios.dart';
import 'native/bannerview_platform_interface.dart';
import 'config.dart';
import 'config_android.dart';
import 'config_ios.dart';
import 'util.dart';

/// Optional callback invoked when a web view is first created. [controller] is
/// the [NativeBannerViewController] for the created banner view.
typedef void NativeBannerViewCreatedCallback(
    NativeBannerViewController controller);

class NativeBannerView extends StatefulWidget {
  const NativeBannerView({
    Key? key,
    this.iOS,
    this.android,
    this.onBannerViewCreated,
    this.gestureRecognizers,
    this.onClick,
    this.onShow,
    this.onDislike,
    this.onError,
  }) : super(key: key);

  final IOSBannerConfig? iOS;
  final AndroidNativeBannerConfig? android;

  /// If not null invoked once the banner view is created.
  final NativeBannerViewCreatedCallback? onBannerViewCreated;

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

  static NativeBannerViewPlatform? _platform;

  /// Sets a custom [BannerViewPlatform].
  ///
  /// This property can be set to use a custom platform implementation for BannerViews.
  ///
  /// Setting `platform` doesn't affect [NativeBannerView]s that were already created.
  ///
  /// The default value is [AndroidBannerView] on Android and [CupertinoBannerView] on iOS.
  static set platform(NativeBannerViewPlatform? platform) {
    _platform = platform;
  }

  /// The BannerView platform that's used by this BannerVIew.
  ///
  /// The default value is [AndroidBannerView] on Android and [CupertinoBannerView] on iOS.
  static NativeBannerViewPlatform get platform {
    if (_platform == null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          _platform = AndroidNativeBannerView();
          break;
        case TargetPlatform.iOS:
          _platform = CupertinoNativeBannerView();
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
  _NativeBannerViewState createState() => _NativeBannerViewState();

  /// 广告被点击
  final VoidCallback? onClick;

  /// 广告展示
  final VoidCallback? onShow;

  /// 点击了关闭按钮（不喜欢）
  final PangleOptionCallback? onDislike;

  /// 获取广告失败
  final PangleMessageCallback? onError;
}

class _NativeBannerViewState extends State<NativeBannerView>
    with AutomaticKeepAliveClientMixin {
  final Completer<NativeBannerViewController> _controller =
      Completer<NativeBannerViewController>();

  _PlatformCallbacksHandler? _platformCallbacksHandler;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NativeBannerView.platform.build(
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
  void didUpdateWidget(NativeBannerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.future.then((NativeBannerViewController controller) {
      _platformCallbacksHandler!._widget = widget;
      controller._updateWidget(widget);
    });
  }

  void _onWebViewPlatformCreated(
    NativeBannerViewPlatformController bannerViewPlatform,
  ) {
    final NativeBannerViewController controller = NativeBannerViewController._(
        widget, bannerViewPlatform, _platformCallbacksHandler);
    _controller.complete(controller);
    if (widget.onBannerViewCreated != null) {
      widget.onBannerViewCreated!(controller);
    }
  }
}

/// Controls a [NativeBannerView].
///
/// A [NativeBannerViewController] instance can be obtained by setting the [NativeBannerView.onBannerViewCreated]
/// callback for a [NativeBannerView] widget.
class NativeBannerViewController {
  NativeBannerViewController._(
    this._widget,
    this._bannerViewPlatformController,
    this._platformCallbacksHandler,
  );

  final NativeBannerViewPlatformController _bannerViewPlatformController;

  // todo unused_field
  // ignore: unused_field
  final _PlatformCallbacksHandler? _platformCallbacksHandler;

  // todo unused_field
  // ignore: unused_field
  NativeBannerView _widget;

  Future<void> _updateWidget(NativeBannerView widget) async {
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

class _PlatformCallbacksHandler
    implements NativeBannerViewPlatformCallbacksHandler {
  _PlatformCallbacksHandler(this._widget);

  NativeBannerView _widget;

  @override
  void onClick() {
    _widget.onClick?.call();
  }

  @override
  void onDislike(String option, bool enforce) {
    _widget.onDislike?.call(option, enforce);
  }

  @override
  void onError(int code, String message) {
    _widget.onError?.call(code, message);
  }

  @override
  void onShow() {
    _widget.onShow?.call();
  }
}
