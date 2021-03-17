import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import 'config_android.dart';
import 'config_ios.dart';
import 'extension.dart';

final kSplashViewType = 'nullptrx.github.io/pangle_splashview';

typedef void SplashViewCreatedCallback(SplashViewController controller);

/// Display banner AD
/// PlatformView does not support Android API level 19 or below.
class SplashView extends StatefulWidget {
  final IOSSplashConfig iOS;
  final AndroidSplashConfig android;

  /// PlatformView 创建成功
  final SplashViewCreatedCallback onSplashViewCreated;
  final Color backgroundColor;

  /// 获取广告失败
  final void Function(int code, String message) onError;

  /// 广告状态改变
  /// 见 [SplashState]
  final StateCallback onStateChanged;

  const SplashView({
    Key key,
    this.iOS,
    this.android,
    this.onSplashViewCreated,
    this.backgroundColor,
    this.onError,
    this.onStateChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: widget.backgroundColor ?? Colors.white,
          width: constraints.biggest.width,
          height: constraints.biggest.height,
          child: _buildPlatformView(
            constraints.biggest.width,
            constraints.biggest.height,
          ),
        );
      },
    );
  }

  void _onPlatformViewCreated(BuildContext context, int id) {
    var controller = SplashViewController._(
      id,
      widget.onError,
      widget.onStateChanged,
    );
    if (widget.onSplashViewCreated == null) {
      return;
    }
    widget.onSplashViewCreated(controller);
  }

  Map<String, dynamic> _createParams(double width, double height) {
    if (Platform.isIOS && widget.iOS != null) {
      var json = widget.iOS.toJSON();
      json['imageSize'] = PangleImageSize(
        width: width,
        height: height,
      ).toJson();
      return json;
    } else if (Platform.isAndroid && widget.android != null) {
      var json = widget.android.toJSON();
      json['imageSize'] = PangleImageSize(
        width: width,
        height: height,
      ).toJson();
      return json;
    }
    return {};
  }

  Widget _buildPlatformView(double width, double height) {
    Widget platformView;
    try {
      var creationParams = _createParams(width, height);
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformView = PlatformViewLink(
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            viewType: kSplashViewType,
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: kSplashViewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: StandardMessageCodec(),
              )
                ..addOnPlatformViewCreatedListener((id) async {
                  params.onPlatformViewCreated(id);
                  _onPlatformViewCreated(context, id);
                })
                ..create();
            });
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView = UiKitView(
          viewType: kSplashViewType,
          onPlatformViewCreated: (index) => _onPlatformViewCreated(
            context,
            index,
          ),
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.ltr,
        );
      } else {
        platformView = Container(
          alignment: Alignment.center,
          child: Text('Not supported platform!'),
        );
      }
    } on PlatformException {}
    return platformView;
  }
}

/// Signature for [SplashViewController.onStateChanged].
typedef FrameCallback = void Function(Duration duration);

/// Signature for [SplashViewController.onStateChanged].
typedef StateCallback = void Function(SplashState state);

enum SplashState {
  /// 倒计时结束
  timeOver,

  /// 广告展示
  show,

  /// 广告被点击
  click,

  /// 跳过广告
  skip,
}

class SplashViewController {
  MethodChannel _methodChannel;

  final void Function(int code, String message) onError;
  final StateCallback onStateChanged;

  SplashViewController._(
    int id,
    this.onError,
    this.onStateChanged,
  ) {
    _methodChannel = new MethodChannel('${kSplashViewType}_$id');
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    if (call.method == 'action') {
      int code = call.arguments['code'];
      String message = call.arguments['message'];
      SplashState state = Enum.enumFromString(SplashState.values, message);
      if (code != 0) {
        if (onError != null) {
          onError(code, message);
        }
      } else {
        if (onStateChanged != null) {
          onStateChanged(state);
        }
      }
    }
    return null;
  }
}
