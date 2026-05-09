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
        return PangleAuthorizationStatus.values.elementAtOrNull(rawValue);
      }
    }
    return null;
  }

  /// Returns information about your application's tracking authorization status.
  ///
  /// Just works on iOS 14.0+.
  Future<PangleAuthorizationStatus?> getTrackingAuthorizationStatus() async {
    if (Platform.isIOS) {
      final int? rawValue = await _methodChannel.invokeMethod(
        'getTrackingAuthorizationStatus',
      );
      if (rawValue != null) {
        return PangleAuthorizationStatus.values.elementAtOrNull(rawValue);
      }
    }
    return null;
  }

  /// Register the App key that's already been applied before requesting an
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
  Future<PangleSplashResult> loadSplashAd({
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
    return PangleSplashResult.fromJson(result);
  }

  /// Display video ad.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// [callback] event callback
  /// return code & message
  ///
  /// 已废弃，请使用 [RewardedAd] 和 [RewardedAdPool] 代替。
  @Deprecated('Use RewardedAd.load() / RewardedAdPool instead.')
  Future<PangleVerifyResult> loadRewardedVideoAd({
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
    return PangleVerifyResult.fromJson(result);
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
  @Deprecated("Use `loadFullscreenVideoAd` instead.")
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
  ///
  /// 已废弃，请使用 [FullscreenAd] 和 [FullscreenAdPool] 代替。
  @Deprecated('Use FullscreenAd.load() / FullscreenAdPool instead.')
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

  // ────────────────────────────────────────────────────────────────────────────
  // 以下为内部方法，供 RewardedAd / FullscreenAd / AdPool 使用，不对外暴露
  // ────────────────────────────────────────────────────────────────────────────

  /// 仅加载激励视频广告到 native 缓存，不展示。
  /// 内部使用，由 [RewardedAd] 调用。
  Future<PangleVerifyResult> loadRewardedVideoAdOnly({
    IOSRewardedVideoConfig? iOS,
    AndroidRewardedVideoConfig? android,
    PangleEventCallback? callback,
  }) async {
    final iosConfig = iOS?.copyWith(loadingType: PangleLoadingType.preloadOnly);
    final androidConfig =
        android?.copyWith(loadingType: PangleLoadingType.preloadOnly);

    final subscription = _eventChannel
        .receiveBroadcastStream(PangleEventType.rewardedVideo.index)
        .listen((dynamic event) {
      callback?.call(event);
    });
    Map<String, dynamic>? result;
    try {
      if (Platform.isIOS && iosConfig != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadRewardedVideoAd',
          iosConfig.toJSON(),
        );
      } else if (Platform.isAndroid && androidConfig != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadRewardedVideoAd',
          androidConfig.toJSON(),
        );
      }
    } finally {
      subscription.cancel();
    }
    return PangleVerifyResult.fromJson(result);
  }

  /// 展示 native 缓存中已加载的激励视频广告。
  /// 内部使用，由 [RewardedAd] 调用。
  Future<PangleVerifyResult> showRewardedVideoAd({
    required String slotId,
    PangleEventCallback? callback,
  }) async {
    final subscription = _eventChannel
        .receiveBroadcastStream(PangleEventType.rewardedVideo.index)
        .listen((dynamic event) {
      callback?.call(event);
    });
    Map<String, dynamic>? result;
    try {
      result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'showRewardedVideoAd',
        {'slotId': slotId},
      );
    } finally {
      subscription.cancel();
    }
    return PangleVerifyResult.fromJson(result);
  }

  /// 查询 native 缓存中是否有可用（未过期）的激励视频广告。
  /// 内部使用，由 [RewardedAdPool] 调用。
  Future<bool> hasRewardedVideoAd(String slotId) async {
    final bool? has = await _methodChannel.invokeMethod<bool>(
      'hasRewardedVideoAd',
      {'slotId': slotId},
    );
    return has ?? false;
  }

  /// 仅加载全屏视频广告到 native 缓存，不展示。
  /// 内部使用，由 [FullscreenAd] 调用。
  Future<PangleResult> loadFullscreenVideoAdOnly({
    IOSFullscreenVideoConfig? iOS,
    AndroidFullscreenVideoConfig? android,
    PangleEventCallback? callback,
  }) async {
    final iosConfig = iOS?.copyWith(loadingType: PangleLoadingType.preloadOnly);
    final androidConfig =
        android?.copyWith(loadingType: PangleLoadingType.preloadOnly);

    final subscription = _eventChannel
        .receiveBroadcastStream(PangleEventType.fullscreen.index)
        .listen((dynamic event) {
      callback?.call(event);
    });
    Map<String, dynamic>? result;
    try {
      if (Platform.isIOS && iosConfig != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadFullscreenVideoAd',
          iosConfig.toJSON(),
        );
      } else if (Platform.isAndroid && androidConfig != null) {
        result = await _methodChannel.invokeMapMethod<String, dynamic>(
          'loadFullscreenVideoAd',
          androidConfig.toJSON(),
        );
      }
    } finally {
      subscription.cancel();
    }
    return PangleResult.fromJson(result);
  }

  /// 展示 native 缓存中已加载的全屏视频广告。
  /// 内部使用，由 [FullscreenAd] 调用。
  Future<PangleResult> showFullscreenVideoAd({
    required String slotId,
    PangleEventCallback? callback,
  }) async {
    final subscription = _eventChannel
        .receiveBroadcastStream(PangleEventType.fullscreen.index)
        .listen((dynamic event) {
      callback?.call(event);
    });
    Map<String, dynamic>? result;
    try {
      result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'showFullscreenVideoAd',
        {'slotId': slotId},
      );
    } finally {
      subscription.cancel();
    }
    return PangleResult.fromJson(result);
  }

  /// 查询 native 缓存中是否有可用（未过期）的全屏视频广告。
  /// 内部使用，由 [FullscreenAdPool] 调用。
  Future<bool> hasFullscreenVideoAd(String slotId) async {
    final bool? has = await _methodChannel.invokeMethod<bool>(
      'hasFullscreenVideoAd',
      {'slotId': slotId},
    );
    return has ?? false;
  }

  /// EventChannel stream，供 Ad 对象订阅事件。
  Stream<dynamic> rewardedVideoEventStream() =>
      _eventChannel.receiveBroadcastStream(PangleEventType.rewardedVideo.index);

  Stream<dynamic> fullscreenEventStream() =>
      _eventChannel.receiveBroadcastStream(PangleEventType.fullscreen.index);
}
