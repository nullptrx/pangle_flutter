import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../util.dart';

const _kEcMallViewType = 'nullptrx.github.io/pangle_ecmallview';

class EcMallView extends StatefulWidget {
  const EcMallView({
    super.key,
    required this.slotId,
    required this.width,
    required this.height,
    this.userData,
    this.gestureRecognizers,
    this.onClick,
    this.onShow,
    this.onDislike,
    this.onError,
  });

  final String slotId;
  final double width;
  final double height;

  /// 可选，Android 专用，JSON 字符串，传递给 setUserData（奖励金币等配置）
  final String? userData;

  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  final VoidCallback? onClick;
  final VoidCallback? onShow;
  final PangleOptionCallback? onDislike;
  final PangleMessageCallback? onError;

  @override
  State<EcMallView> createState() => _EcMallViewState();
}

class _EcMallViewState extends State<EcMallView>
    with AutomaticKeepAliveClientMixin {
  MethodChannel? _channel;

  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> get _creationParams => {
        'slotId': widget.slotId,
        'width': widget.width,
        'height': widget.height,
        if (widget.userData != null) 'userData': widget.userData,
      };

  void _onPlatformViewCreated(int id) {
    final channel =
        MethodChannel('nullptrx.github.io/pangle_ecmallview_$id');
    channel.setMethodCallHandler(_handleMethodCall);
    _channel = channel;
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onClick':
        widget.onClick?.call();
      case 'onShow':
        widget.onShow?.call();
      case 'onDislike':
        final args = Map<String, dynamic>.from(call.arguments as Map);
        widget.onDislike?.call(
          args['option'] as String? ?? '',
          args['enforce'] as bool? ?? false,
        );
      case 'onError':
        final args = Map<String, dynamic>.from(call.arguments as Map);
        widget.onError?.call(
          args['code'] as int? ?? -1,
          args['message'] as String? ?? '',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: _kEcMallViewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: _creationParams,
          gestureRecognizers: widget.gestureRecognizers,
          creationParamsCodec: const StandardMessageCodec(),
          layoutDirection: TextDirection.ltr,
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: _kEcMallViewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: _creationParams,
          gestureRecognizers: widget.gestureRecognizers,
          creationParamsCodec: const StandardMessageCodec(),
          layoutDirection: TextDirection.ltr,
        );
      default:
        throw UnsupportedError(
            'EcMallView is not supported on $defaultTargetPlatform');
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }
}
