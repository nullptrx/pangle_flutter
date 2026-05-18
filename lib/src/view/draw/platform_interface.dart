import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../platform_controller.dart';

const kDrawViewType = 'nullptrx.github.io/pangle_drawview';

abstract class DrawViewPlatform {
  Widget build({
    required BuildContext context,
    required Map<String, dynamic> creationParams,
    required DrawViewPlatformCallbacksHandler callbacksHandler,
    DrawViewPlatformCreatedCallback? onPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  });
}

typedef DrawViewPlatformCreatedCallback = void Function(
    DrawViewPlatformController controller);

abstract class DrawViewPlatformController implements PlatformController {}

abstract class DrawViewPlatformCallbacksHandler {
  void onClick();
  void onShow();
  void onRenderSuccess(double width, double height);
  void onRenderFail(int code, String message);
  void onDislike(String option, bool enforce);
}
