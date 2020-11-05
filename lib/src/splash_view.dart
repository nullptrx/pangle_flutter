import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import 'config_android.dart';
import 'config_ios.dart';

final kSplashViewType = 'nullptrx.github.io/pangle_splashview';

typedef void SplashViewCreatedCallback(SplashViewController controller);

/// Display banner AD
/// PlatformView does not support Android API level 19 or below.
class SplashView extends StatefulWidget {
  final IOSSplashConfig iOS;
  final AndroidSplashConfig android;
  final SplashViewCreatedCallback onSplashViewCreated;
  final Color backgroundColor;
  final void Function(int code, String message) onError;
  final VoidCallback onClick;
  final VoidCallback onSkip;
  final VoidCallback onTimeOver;
  final VoidCallback onShow;

  const SplashView({
    Key key,
    this.iOS,
    this.android,
    this.onSplashViewCreated,
    this.backgroundColor,
    this.onError,
    this.onClick,
    this.onSkip,
    this.onTimeOver,
    this.onShow,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> with WidgetsBindingObserver {
  SplashViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
      widget.onClick,
      widget.onSkip,
      widget.onTimeOver,
      widget.onShow,
    );
    _controller = controller;
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
    Widget body;
    try {
      Widget platformView;
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformView = AndroidView(
          viewType: kSplashViewType,
          onPlatformViewCreated: (index) =>
              _onPlatformViewCreated(context, index),
          creationParams: _createParams(width, height),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.ltr,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView = UiKitView(
          viewType: kSplashViewType,
          onPlatformViewCreated: (index) =>
              _onPlatformViewCreated(context, index),
          creationParams: _createParams(width, height),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.ltr,
        );
      }
      if (platformView != null) {
        body = platformView;
      }
    } on PlatformException {}
    if (body == null) {
      body = SizedBox.expand();
    }
    return body;
  }
}

class SplashViewController {
  MethodChannel _methodChannel;

  final void Function(int code, String message) onError;
  final VoidCallback onClick;
  final VoidCallback onSkip;
  final VoidCallback onTimeOver;
  final VoidCallback onShow;

  SplashViewController._(
    int id,
    this.onError,
    this.onClick,
    this.onSkip,
    this.onTimeOver,
    this.onShow,
  ) {
    _methodChannel = new MethodChannel('${kSplashViewType}_$id');
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    if (call.method == 'action') {
      var code = call.arguments['code'];
      var message = call.arguments['message'];
      switch (message) {
        case 'click':
          onClick?.call();
          break;
        case 'skip':
          onSkip?.call();
          break;
        case 'timeover':
          onTimeOver?.call();
          break;
        case 'show':
          onShow?.call();
          break;
        default:
          onError?.call(code, message);
          break;
      }
    }
    return null;
  }
}
