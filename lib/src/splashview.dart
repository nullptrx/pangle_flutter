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

import 'config.dart';
import 'config_android.dart';
import 'config_ios.dart';
import 'splash/platform_interface.dart';
import 'splash/splashview_android.dart';
import 'splash/splashview_ios.dart';
import 'util.dart';

/// Optional callback invoked when a web view is first created. [controller] is
/// the [SplashViewController] for the created splash view.
typedef void SplashViewCreatedCallback(SplashViewController controller);

class SplashView extends StatefulWidget {
  const SplashView({
    Key? key,
    this.iOS,
    this.android,
    this.onSplashViewCreated,
    this.gestureRecognizers,
    this.onClick,
    this.onSkip,
    this.onShow,
    this.onTimeOver,
    this.onError,
  }) : super(key: key);

  final IOSSplashConfig? iOS;
  final AndroidSplashConfig? android;

  /// If not null invoked once the splash view is created.
  final SplashViewCreatedCallback? onSplashViewCreated;

  /// Which gestures should be consumed by the splash view.
  ///
  /// It is possible for other gesture recognizers to be competing with the splash view on pointer
  /// events, e.g if the splash view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The splash view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the splash view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  static SplashViewPlatform? _platform;

  /// Sets a custom [SplashViewPlatform].
  ///
  /// This property can be set to use a custom platform implementation for SplashViews.
  ///
  /// Setting `platform` doesn't affect [SplashView]s that were already created.
  ///
  /// The default value is [AndroidSplashView] on Android and [CupertinoSplashView] on iOS.
  static set platform(SplashViewPlatform platform) {
    _platform = platform;
  }

  /// The SplashView platform that's used by this SplashVIew.
  ///
  /// The default value is [AndroidSplashView] on Android and [CupertinoSplashView] on iOS.
  static SplashViewPlatform get platform {
    if (_platform == null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          _platform = AndroidSplashView();
          break;
        case TargetPlatform.iOS:
          _platform = CupertinoSplashView();
          break;
        default:
          throw UnsupportedError(
              "Trying to use the default splashview implementation for $defaultTargetPlatform but there isn't a default one");
      }
    }
    return _platform!;
  }

  Config get config {
    Config config;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        config = android!;
        break;
      case TargetPlatform.iOS:
        config = iOS!;
        break;
      default:
        throw UnsupportedError(
            "Trying to use the default splashview implementation for $defaultTargetPlatform but there isn't a default one");
    }
    return config;
  }

  @override
  _SplashViewState createState() => _SplashViewState();

  /// 广告被点击
  final VoidCallback? onClick;

  /// 跳过广告
  final VoidCallback? onSkip;

  /// 广告展示
  final VoidCallback? onShow;

  /// 倒计时结束
  final VoidCallback? onTimeOver;

  /// 获取广告失败
  final PangleMessageCallback? onError;
}

class _SplashViewState extends State<SplashView>
    with AutomaticKeepAliveClientMixin {
  final Completer<SplashViewController> _controller =
      Completer<SplashViewController>();

  _PlatformCallbacksHandler? _platformCallbacksHandler;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SplashView.platform.build(
      context: context,
      creationParams: widget.config.toJSON(),
      splashViewPlatformCallbacksHandler: _platformCallbacksHandler!,
      onSplashViewPlatformCreated: _onWebViewPlatformCreated,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  @override
  void initState() {
    super.initState();
    _platformCallbacksHandler = _PlatformCallbacksHandler(widget);
  }

  @override
  void didUpdateWidget(SplashView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.future.then((SplashViewController controller) {
      _platformCallbacksHandler!._widget = widget;
      controller._updateWidget(widget);
    });
  }

  void _onWebViewPlatformCreated(
    SplashViewPlatformController splashViewPlatform,
  ) {
    final SplashViewController controller = SplashViewController._(
        widget, splashViewPlatform, _platformCallbacksHandler);
    _controller.complete(controller);
    if (widget.onSplashViewCreated != null) {
      widget.onSplashViewCreated!(controller);
    }
  }
}

/// Controls a [SplashView].
///
/// A [SplashViewController] instance can be obtained by setting the [SplashView.onSplashViewCreated]
/// callback for a [SplashView] widget.
class SplashViewController {
  SplashViewController._(
    this._widget,
    this._splashViewPlatformController,
    this._platformCallbacksHandler,
  );

  // todo unused_field
  // ignore: unused_field
  final SplashViewPlatformController _splashViewPlatformController;

  // todo unused_field
  // ignore: unused_field
  final _PlatformCallbacksHandler? _platformCallbacksHandler;

  // todo unused_field
  // ignore: unused_field
  SplashView _widget;

  Future<void> _updateWidget(SplashView widget) async {
    _widget = widget;
  }
}

class _PlatformCallbacksHandler implements SplashViewPlatformCallbacksHandler {
  _PlatformCallbacksHandler(this._widget);

  SplashView _widget;

  @override
  void onClick() {
    _widget.onClick?.call();
  }

  @override
  void onShow() {
    _widget.onShow?.call();
  }

  @override
  void onSkip() {
    _widget.onSkip?.call();
  }

  @override
  void onTimeOver() {
    _widget.onTimeOver?.call();
  }

  @override
  void onError(int code, String message) {
    _widget.onError?.call(code, message);
  }
}
