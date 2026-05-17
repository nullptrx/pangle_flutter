import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'drawview_method_channel.dart';
import 'platform_interface.dart';

class AndroidDrawView implements DrawViewPlatform {
  const AndroidDrawView();

  @override
  Widget build({
    required BuildContext context,
    required Map<String, dynamic> creationParams,
    required DrawViewPlatformCallbacksHandler callbacksHandler,
    DrawViewPlatformCreatedCallback? onPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    return GestureDetector(
      onLongPress: () {},
      excludeFromSemantics: true,
      child: AndroidView(
        viewType: kDrawViewType,
        gestureRecognizers: gestureRecognizers ??
            const <Factory<OneSequenceGestureRecognizer>>{},
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        onPlatformViewCreated: (id) {
          if (onPlatformCreated == null) return;
          onPlatformCreated(MethodChannelDrawViewPlatform(id, callbacksHandler));
        },
      ),
    );
  }
}
