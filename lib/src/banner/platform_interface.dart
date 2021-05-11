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
import 'package:flutter/widgets.dart';

final kBannerViewType = 'nullptrx.github.io/pangle_bannerview';

abstract class BannerViewPlatform {
  Widget build({
    required BuildContext context,
    required Map<String, dynamic> creationParams,
    required BannerViewPlatformCallbacksHandler
        bannerViewPlatformCallbacksHandler,
    BannerViewPlatformCreatedCallback? onBannerViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  });
}

/// Signature for callbacks reporting that a [BannerViewPlatformController] was created.
///
/// See also the `onBannerViewPlatformCreated` argument for [BannerViewPlatform.build].
typedef BannerViewPlatformCreatedCallback = void Function(
    BannerViewPlatformController bannerViewPlatformController);

/// Interface for talking to the bannerview's platform implementation.
///
/// An instance implementing this interface is passed to the `onBannerViewPlatformCreated` callback that is
/// passed to [BannerViewPlatformBuilder#onBannerViewPlatformCreated].
///
/// Platform implementations that live in a separate package should extend this class rather than
/// implement it as pangle_flutter does not consider newly added methods to be breaking changes.
/// Extending this class (using `extends`) ensures that the subclass will get the default
/// implementation, while platform implementations that `implements` this interface will be broken
/// by newly added [BannerViewPlatformController] methods.
abstract class BannerViewPlatformController {
  /// 更新可点击区域
  Future<void> updateTouchableBounds(List<Rect> bounds);

  /// 更新不可点击区域
  Future<void> updateRestrictedBounds(List<Rect> bounds);
}

/// Interface for callbacks made by [BannerViewPlatformController].
///
/// The bannerview plugin implements this class, and passes an instance to the [BannerViewPlatformController].
/// [BannerViewPlatformController] is notifying this handler on events that happened on the platform's bannerview.
abstract class BannerViewPlatformCallbacksHandler {
  void onClick();

  void onShow();

  void onRenderSuccess();

  void onRenderFail(int code, String message);

  void onError(int code, String message);

  /// [option]
  /// [enforce] 当enforce参数返回true时，代表穿山甲会主动关闭掉广告，广告移除后需要开发者对界面进行适配。
  void onDislike(String option, bool enforce);
}
