import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'platform_interface.dart';

class MethodChannelDrawViewPlatform implements DrawViewPlatformController {
  MethodChannelDrawViewPlatform(int id, this._callbacksHandler)
      : _channel = MethodChannel('${kDrawViewType}_$id') {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  final DrawViewPlatformCallbacksHandler _callbacksHandler;
  final MethodChannel _channel;

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onClick':
        _callbacksHandler.onClick();
        break;
      case 'onShow':
        _callbacksHandler.onShow();
        break;
      case 'onDislike':
        final String option = call.arguments['option'];
        final bool enforce = call.arguments['enforce'] ?? false;
        _callbacksHandler.onDislike(option, enforce);
        break;
      case 'onRenderSuccess':
        final width = (call.arguments?['width'] as num?)?.toDouble() ?? 0.0;
        final height = (call.arguments?['height'] as num?)?.toDouble() ?? 0.0;
        _callbacksHandler.onRenderSuccess(width, height);
        break;
      case 'onRenderFail':
        final int code = call.arguments['code'];
        final String message = call.arguments['message'];
        _callbacksHandler.onRenderFail(code, message);
        break;
    }
  }

  @override
  Future<void> addTouchableBounds(List<Rect> bounds) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return;
    final json = bounds
        .map((b) => {'x': b.left, 'y': b.top, 'w': b.width, 'h': b.height})
        .toList();
    await _channel.invokeMethod<void>('addTouchableBounds', json);
  }

  @override
  Future<void> clearTouchableBounds() async {
    await _channel.invokeMethod<void>('clearTouchableBounds');
  }
}
