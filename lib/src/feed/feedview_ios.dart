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

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'feedview_method_channel.dart';
import 'platform_interface.dart';

class CupertinoFeedView implements FeedViewPlatform {
  @override
  Widget build({
    BuildContext context,
    Map<String, dynamic> creationParams,
    FeedViewPlatformCallbacksHandler feedViewPlatformCallbacksHandler,
    FeedViewPlatformCreatedCallback onFeedViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
  }) {
    return UiKitView(
      viewType: kFeedViewType,
      onPlatformViewCreated: (id) {
        if (onFeedViewPlatformCreated == null) {
          return;
        }
        onFeedViewPlatformCreated(MethodChannelFeedViewPlatform(
            id, feedViewPlatformCallbacksHandler));
      },
      creationParams: creationParams,
      gestureRecognizers: gestureRecognizers,
      creationParamsCodec: const StandardMessageCodec(),
      // FeedView content is not affected by the Android view's layout direction,
      // we explicitly set it here so that the widget doesn't require an ambient
      // directionality.
      layoutDirection: TextDirection.ltr,
    );
  }
}
