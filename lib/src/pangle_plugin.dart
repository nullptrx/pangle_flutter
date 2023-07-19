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

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'build.dart';
import 'config_android.dart';
import 'config_ios.dart';
import 'constant.dart';
import 'model.dart';
import 'pangle_event_type.dart';

final pangle = PanglePlugin._();

typedef PangleEventCallback = void Function(String event);

/// Pangle Ad Plugin
class PanglePlugin {
  static const MethodChannel _methodChannel = MethodChannel(
    'nullptrx.github.io/pangle',
  );
  static const EventChannel _eventChannel = EventChannel(
    'nullptrx.github.io/pangle_event',
  );

  PanglePlugin._() {
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {}

  /// 获取AndroidSDKVersion
  Future<AndroidDeviceInfo> getAndroidDeviceInfo() async {
    final Map<String, dynamic>? deviceInfo =
        await _methodChannel.invokeMapMethod<String, dynamic>('getDeviceInfo');

    return AndroidDeviceInfo.fromMap(deviceInfo!);
  }

  /// 获取SDK版本号
  Future<IOSDeviceInfo> getIOSDeviceInfo() async {
    final Map<String, dynamic>? deviceInfo =
        await _methodChannel.invokeMapMethod<String, dynamic>('getDeviceInfo');

    return IOSDeviceInfo.fromMap(deviceInfo!);
  }

  /// 获取SDK版本号
  Future<String?> getSdkVersion() async {
    return await _methodChannel.invokeMethod('getSdkVersion');
  }

  /// 获取当前主题类型
  /// 0：正常模式；1：夜间模式
  Future<PangleTheme> getThemeStatus() async {
    final int? status =
        await _methodChannel.invokeMethod<int>('getThemeStatus');
    if (status == 1) {
      return PangleTheme.dark;
    }
    return PangleTheme.light;
  }

  /// 设置主题类型
  /// [theme] 0：正常模式；1：夜间模式；默认为0；传非法值，按照0处理
  Future<PangleTheme> setThemeStatus(PangleTheme theme) async {
    final int? status =
        await _methodChannel.invokeMethod<int>('setThemeStatus', theme.index);
    if (status == 1) {
      return PangleTheme.dark;
    }
    return PangleTheme.light;
  }

  /// 请求权限（仅国内Android）
  ///
  /// 穿山甲SDK不强制获取权限，即使没有获取可选权限SDK也能正常运行；
  /// 获取权限将帮助穿山甲优化投放广告精准度和用户的交互体验，提高eCPM。
  /// 常见问题：
  /// 使用该方法请求权限时 FlutterActivity不会回调onStart,onStop方法，会导致插屏广告
  /// (Interstitial Ad)不能正常显示。详见 Android SDK
  ///   [com.bytedance.sdk.openadsdk.utils.a:28],
  ///   [com.bytedance.sdk.openadsdk.core.c.b:306].
  /// 建议自行实现权限请求, 如使用[permission_handler](https://pub.flutter-io.cn/packages?q=permission_handler)
  ///
  /// ```
  /// [Permission.location, Permission.phone, Permission.storage].request();
  /// ```
  Future<void> requestPermissionIfNecessary() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod<void>('requestPermissionIfNecessary');
    }
  }

  /// 显示隐私保护协议弹窗（仅海外）
  /// ```
  Future<void> showPrivacyProtection() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod<void>('showPrivacyProtection');
    }
  }

  /// Request user tracking authorization with a completion handler returning
  /// the user's authorization status.
  /// Users are able to grant or deny developers tracking privileges on a
  /// per-app basis.This method allows developers to determine if access has
  /// been granted. On first use, this method will prompt the user to grant or
  /// deny access.
  ///
  /// Just works on iOS 14.0+.
  Future<PangleAuthorizationStatus?> requestTrackingAuthorization() async {
    if (Platform.isIOS) {
      final int? rawValue = await _methodChannel.invokeMethod(
        'requestTrackingAuthorization',
      );
      if (rawValue != null) {
        return PangleAuthorizationStatus.values[rawValue];
      }
    }
    return null;
  }

  /// Returns information about your application’s tracking authorization status.
  ///
  /// Just works on iOS 14.0+.
  Future<PangleAuthorizationStatus?> getTrackingAuthorizationStatus() async {
    if (Platform.isIOS) {
      final int? rawValue = await _methodChannel.invokeMethod(
        'getTrackingAuthorizationStatus',
      );
      if (rawValue != null) {
        return PangleAuthorizationStatus.values[rawValue];
      }
    }
    return null;
  }

  /// 是否遵循隐私协议的选择框
  /// 也可自定义设置GDPR，用来标识本次广告是否遵循欧盟通用数据保护条例。
  Future<bool> openGDPRPrivacy() async {
    if (Platform.isIOS) {
      final bool? confirm =
          await _methodChannel.invokeMethod<bool>('openGDPRPrivacy');
      return confirm ?? false;
    }
    return false;
  }

  /// Register the App key that’s already been applied before requesting an
  /// ad from TikTok Audience Network.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  Future<PangleResult> init({
    IOSConfig? iOS,
    AndroidConfig? android,
  }) async {
    Map<String, dynamic>? result;
    if (Platform.isIOS && iOS != null) {
      result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'init',
        iOS.toJSON(),
      );
    } else if (Platform.isAndroid && android != null) {
      result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'init',
        android.toJSON(),
      );
    }
    return PangleResult.fromJson(result);
  }

  /// Load splash ad datas.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  Future<PangleResult> loadSplashAd({
    IOSSplashConfig? iOS,
    AndroidSplashConfig? android,
  }) async {
    Map<String, dynamic>? result;
    if (Platform.isIOS && iOS != null) {
      result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'loadSplashAd',
        iOS.toJSON(),
      );
    } else if (Platform.isAndroid && android != null) {
      result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'loadSplashAd',
        android.toJSON(),
      );
    }
    return PangleResult.fromJson(result);
  }

  /// Display video ad.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// [callback] event callback
  /// return code & message
  Future<PangleResult> loadRewardedVideoAd({
    IOSRewardedVideoConfig? iOS,
    AndroidRewardedVideoConfig? android,
    PangleEventCallback? callback,
  }) async {
    final subscription = _eventChannel
        .receiveBroadcastStream(PangleEventType.rewardedVideo.index)
        .listen((dynamic event) {
      callback?.call(event);
    });
    Map<String, dynamic>? result;
    try {
      if (Platform.isIOS && iOS != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadRewardedVideoAd',
          iOS.toJSON(),
        );
      } else if (Platform.isAndroid && android != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadRewardedVideoAd',
          android.toJSON(),
        );
      }
    } finally {
      subscription.cancel();
    }
    return PangleResult.fromJson(result);
  }

  /// Request feed ad data.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// return loaded ad count.
  Future<PangleAd> loadFeedAd({
    IOSFeedConfig? iOS,
    AndroidFeedConfig? android,
  }) async {
    Map<dynamic, dynamic>? result;
    if (Platform.isIOS && iOS != null) {
      result = await _methodChannel.invokeMapMethod<dynamic, dynamic>(
        'loadFeedAd',
        iOS.toJSON(),
      );
    } else if (Platform.isAndroid && android != null) {
      result = await _methodChannel.invokeMapMethod<dynamic, dynamic>(
        'loadFeedAd',
        android.toJSON(),
      );
    }
    if (result == null) {
      return PangleAd.empty();
    }
    return PangleAd.fromJsonMap(result);
  }

  /// Remove feed ad references
  /// [ids] feed id, see [loadFeedAd]
  /// return count of removed
  Future<int?> removeFeedAd(List<String> ids) async {
    return await _methodChannel.invokeMethod('removeFeedAd', ids);
  }

  /// Request interstitial ad data.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// [callback] event callback
  /// return loaded ad count.
  Future<PangleResult> loadInterstitialAd({
    IOSInterstitialConfig? iOS,
    AndroidInterstitialConfig? android,
    PangleEventCallback? callback,
  }) async {
    final subscription = _eventChannel
        .receiveBroadcastStream(PangleEventType.interstitial.index)
        .listen((dynamic event) {
      callback?.call(event);
    });
    Map<String, dynamic>? result;
    try {
      if (Platform.isIOS && iOS != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadInterstitialAd',
          iOS.toJSON(),
        );
      } else if (Platform.isAndroid && android != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadInterstitialAd',
          android.toJSON(),
        );
      }
    } finally {
      subscription.cancel();
    }
    return PangleResult.fromJson(result);
  }

  /// Request full screen video ad data.
  ///
  /// 全屏视频广告，新模板渲染插屏
  /// [iOS] config for iOS
  /// [android] config for Android
  /// [callback] event callback
  /// return code & message.
  Future<PangleResult> loadFullscreenVideoAd({
    IOSFullscreenVideoConfig? iOS,
    AndroidFullscreenVideoConfig? android,
    PangleEventCallback? callback,
  }) async {
    final subscription = _eventChannel
        .receiveBroadcastStream(PangleEventType.fullscreen.index)
        .listen((dynamic event) {
      callback?.call(event);
    });
    Map<String, dynamic>? result;
    try {
      if (Platform.isIOS && iOS != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadFullscreenVideoAd',
          iOS.toJSON(),
        );
      } else if (Platform.isAndroid && android != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadFullscreenVideoAd',
          android.toJSON(),
        );
      }
    } finally {
      subscription.cancel();
    }
    return PangleResult.fromJson(result);
  }
}
