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

import 'package:flutter/services.dart';

import 'feedview_platform_interface.dart';

/// A [NativeFeedViewPlatformController] that uses a method channel to control the feedview.
class MethodChannelNativeFeedViewPlatform
    implements NativeFeedViewPlatformController {
  /// Constructs an instance that will listen for webviews broadcasting to the
  /// given [id], using the given [WebViewPlatformCallbacksHandler].
  MethodChannelNativeFeedViewPlatform(int id, this._platformCallbacksHandler)
      : _channel = MethodChannel('${kNativeFeedViewType}_$id') {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  final NativeFeedViewPlatformCallbacksHandler _platformCallbacksHandler;

  final MethodChannel _channel;

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onClick":
        _platformCallbacksHandler.onClick();
        break;
      case "onShow":
        _platformCallbacksHandler.onShow();
        break;
      case "onDislike":
        String option = call.arguments['option'];
        bool enforce = call.arguments['enforce'];
        _platformCallbacksHandler.onDislike(option, enforce);
        break;
    }
  }
}
