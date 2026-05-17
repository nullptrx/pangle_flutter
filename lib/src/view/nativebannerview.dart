import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../util.dart';

const _kNativeBannerViewType = 'nullptrx.github.io/pangle_nativebannerview';

typedef NativeBannerViewCreatedCallback = void Function(
    MethodChannel controller);

class NativeBannerView extends StatefulWidget {
  const NativeBannerView({
    super.key,
    required this.slotId,
    required this.width,
    required this.height,
    this.gestureRecognizers,
    this.onClick,
    this.onShow,
    this.onDislike,
    this.onError,
  });

  final String slotId;
  final double width;
  final double height;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  final VoidCallback? onClick;
  final VoidCallback? onShow;
  final PangleOptionCallback? onDislike;
  final PangleMessageCallback? onError;

  @override
  State<NativeBannerView> createState() => _NativeBannerViewState();
}

class _NativeBannerViewState extends State<NativeBannerView>
    with AutomaticKeepAliveClientMixin {
  MethodChannel? _channel;

  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> get _creationParams => {
        'slotId': widget.slotId,
        'size': {'width': widget.width, 'height': widget.height},
      };

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel(
        'nullptrx.github.io/pangle_nativebannerview_$id');
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
          viewType: _kNativeBannerViewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: _creationParams,
          gestureRecognizers: widget.gestureRecognizers,
          creationParamsCodec: const StandardMessageCodec(),
          layoutDirection: TextDirection.ltr,
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: _kNativeBannerViewType,
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: _creationParams,
          gestureRecognizers: widget.gestureRecognizers,
          creationParamsCodec: const StandardMessageCodec(),
          layoutDirection: TextDirection.ltr,
        );
      default:
        throw UnsupportedError(
            'NativeBannerView is not supported on $defaultTargetPlatform');
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }
}
