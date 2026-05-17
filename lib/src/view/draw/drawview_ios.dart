import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'drawview_method_channel.dart';
import 'platform_interface.dart';

class CupertinoDrawView implements DrawViewPlatform {
  const CupertinoDrawView();

  @override
  Widget build({
    required BuildContext context,
    required Map<String, dynamic> creationParams,
    required DrawViewPlatformCallbacksHandler callbacksHandler,
    DrawViewPlatformCreatedCallback? onPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    return UiKitView(
      viewType: kDrawViewType,
      onPlatformViewCreated: (id) {
        if (onPlatformCreated == null) return;
        onPlatformCreated(MethodChannelDrawViewPlatform(id, callbacksHandler));
      },
      creationParams: creationParams,
      gestureRecognizers: gestureRecognizers,
      creationParamsCodec: const StandardMessageCodec(),
      layoutDirection: TextDirection.ltr,
    );
  }
}
