import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../util.dart';
import 'draw/drawview_android.dart';
import 'draw/drawview_ios.dart';
import 'draw/platform_interface.dart';
import 'platform_controller.dart';

typedef DrawViewCreatedCallback = void Function(DrawViewController controller);

/// Draw 竖版全屏广告 Widget。
///
/// 使用前先调用 [pangle.loadDrawAd()] 获取 id，再传入此 Widget。
/// 通常嵌入全屏 [PageView] 中实现 TikTok 风格滑动效果。
class DrawView extends StatefulWidget {
  const DrawView({
    super.key,
    this.id,
    this.onDrawViewCreated,
    this.gestureRecognizers,
    this.onClick,
    this.onShow,
    this.onDislike,
    this.onRenderSuccess,
    this.onRenderFail,
  });

  final String? id;

  final DrawViewCreatedCallback? onDrawViewCreated;

  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  final VoidCallback? onClick;
  final VoidCallback? onShow;
  final PangleOptionCallback? onDislike;
  final void Function(double width, double height)? onRenderSuccess;
  final PangleMessageCallback? onRenderFail;

  static DrawViewPlatform? _platform;

  static set platform(DrawViewPlatform platform) {
    _platform = platform;
  }

  static DrawViewPlatform get platform {
    if (_platform == null) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          _platform = const AndroidDrawView();
          break;
        case TargetPlatform.iOS:
          _platform = const CupertinoDrawView();
          break;
        default:
          throw UnsupportedError(
              'DrawView is not supported on $defaultTargetPlatform');
      }
    }
    return _platform!;
  }

  Map<String, dynamic> get config {
    return <String, dynamic>{
      'id': id,
      'isUserInteractionEnabled': false,
    };
  }

  @override
  DrawViewState createState() => DrawViewState();
}

class DrawViewState extends State<DrawView>
    with AutomaticKeepAliveClientMixin {
  _CallbacksHandler? _callbacksHandler;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DrawView.platform.build(
      context: context,
      creationParams: widget.config,
      callbacksHandler: _callbacksHandler!,
      onPlatformCreated: _onPlatformCreated,
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  @override
  void initState() {
    super.initState();
    _callbacksHandler = _CallbacksHandler(widget);
  }

  @override
  void didUpdateWidget(DrawView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _callbacksHandler!._widget = widget;
  }

  void _onPlatformCreated(DrawViewPlatformController platform) {
    final controller = DrawViewController._(platform);
    widget.onDrawViewCreated?.call(controller);
  }
}

class DrawViewController extends ViewController {
  DrawViewController._(DrawViewPlatformController super.controller);
}

class _CallbacksHandler implements DrawViewPlatformCallbacksHandler {
  _CallbacksHandler(this._widget);

  DrawView _widget;

  @override
  void onClick() => _widget.onClick?.call();

  @override
  void onShow() => _widget.onShow?.call();

  @override
  void onDislike(String option, bool enforce) =>
      _widget.onDislike?.call(option, enforce);

  @override
  void onRenderSuccess(double width, double height) =>
      _widget.onRenderSuccess?.call(width, height);

  @override
  void onRenderFail(int code, String message) =>
      _widget.onRenderFail?.call(code, message);
}
