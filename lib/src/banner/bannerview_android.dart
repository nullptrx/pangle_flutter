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
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'bannerview_method_channel.dart';
import 'platform_interface.dart';

class AndroidBannerView implements BannerViewPlatform {
  @override
  Widget build({
    @required BuildContext context,
    @required Map<String, dynamic> creationParams,
    @required
        BannerViewPlatformCallbacksHandler bannerViewPlatformCallbacksHandler,
    BannerViewPlatformCreatedCallback onBannerViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
  }) {
    return PlatformViewLink(
        viewType: kBannerViewType,
        surfaceFactory: (
          BuildContext context,
          PlatformViewController controller,
        ) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: gestureRecognizers ??
                const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: kBannerViewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener((id) async {
              if (onBannerViewPlatformCreated == null) {
                return;
              }
              onBannerViewPlatformCreated(MethodChannelBannerViewPlatform(
                id,
                bannerViewPlatformCallbacksHandler,
              ));
            })
            ..create();
        });
  }
}
