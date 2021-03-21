import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'config_android.dart';
import 'config_ios.dart';
import 'constant.dart';
import 'model.dart';

final pangle = PanglePlugin._();

/// Pangle Ad Plugin
class PanglePlugin {
  static const MethodChannel _methodChannel = const MethodChannel(
    'nullptrx.github.io/pangle',
  );

  PanglePlugin._() {
    _methodChannel.setMethodCallHandler((call) => _handleMethod(call));
  }

  _handleMethod(MethodCall call) {}

  Future<String> getSdkVersion() async {
    return await _methodChannel.invokeMethod('getSdkVersion');
  }

  /// Request permissions
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
  Future<Null> requestPermissionIfNecessary() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod('requestPermissionIfNecessary');
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
  Future<PangleAuthorizationStatus> requestTrackingAuthorization() async {
    if (Platform.isIOS) {
      int rawValue = await _methodChannel.invokeMethod(
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
  Future<PangleAuthorizationStatus> getTrackingAuthorizationStatus() async {
    if (Platform.isIOS) {
      int rawValue = await _methodChannel.invokeMethod(
        'getTrackingAuthorizationStatus',
      );
      if (rawValue != null) {
        return PangleAuthorizationStatus.values[rawValue];
      }
    }
    return null;
  }

  /// Register the App key that’s already been applied before requesting an
  /// ad from TikTok Audience Network.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  Future<Null> init({
    IOSConfig iOS,
    AndroidConfig android,
  }) async {
    if (Platform.isIOS && iOS != null) {
      await _methodChannel.invokeMethod('init', iOS.toJSON());
    } else if (Platform.isAndroid && android != null) {
      await _methodChannel.invokeMethod('init', android.toJSON());
    }
  }

  /// Load splash ad datas.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  Future<PangleResult> loadSplashAd({
    IOSSplashConfig iOS,
    AndroidSplashConfig android,
  }) async {
    Map<String, dynamic> result;
    if (Platform.isIOS && iOS != null) {
      result = await _methodChannel.invokeMapMethod(
        'loadSplashAd',
        iOS.toJSON(),
      );
    } else if (Platform.isAndroid && android != null) {
      result = await _methodChannel.invokeMapMethod(
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
  /// return code & message
  Future<PangleResult> loadRewardedVideoAd({
    IOSRewardedVideoConfig iOS,
    AndroidRewardedVideoConfig android,
  }) async {
    Map<String, dynamic> result;
    if (Platform.isIOS && iOS != null) {
      result = await _methodChannel.invokeMapMethod(
        'loadRewardedVideoAd',
        iOS.toJSON(),
      );
    } else if (Platform.isAndroid && android != null) {
      result = await _methodChannel.invokeMapMethod(
        'loadRewardedVideoAd',
        android.toJSON(),
      );
    }
    return PangleResult.fromJson(result);
  }

  /// Request feed ad data.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// return loaded ad count.
  Future<PangleAd> loadFeedAd({
    IOSFeedConfig iOS,
    AndroidFeedConfig android,
  }) async {
    Map<dynamic, dynamic> result;
    if (Platform.isIOS && iOS != null) {
      result = await _methodChannel.invokeMapMethod(
        'loadFeedAd',
        iOS.toJSON(),
      );
    } else if (Platform.isAndroid && android != null) {
      result = await _methodChannel.invokeMapMethod(
        'loadFeedAd',
        android.toJSON(),
      );
    }
    if (result == null) {
      return PangleAd.empty();
    }
    return PangleAd.fromJsonMap(result);
  }

  /// Request interstitial ad data.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// return loaded ad count.
  Future<PangleResult> loadInterstitialAd({
    IOSInterstitialConfig iOS,
    AndroidInterstitialConfig android,
  }) async {
    Map<String, dynamic> result;
    if (Platform.isIOS && iOS != null) {
      result = await _methodChannel.invokeMapMethod(
        'loadInterstitialAd',
        iOS.toJSON(),
      );
    } else if (Platform.isAndroid && android != null) {
      result = await _methodChannel.invokeMapMethod(
        'loadInterstitialAd',
        android.toJSON(),
      );
    }
    return PangleResult.fromJson(result);
  }

  /// Request full screen video ad data.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// return code & message.
  Future<PangleResult> loadFullscreenVideoAd({
    IOSFullscreenVideoConfig iOS,
    AndroidFullscreenVideoConfig android,
  }) async {
    Map<String, dynamic> result;
    if (Platform.isIOS && iOS != null) {
      result = await _methodChannel.invokeMapMethod(
        'loadFullscreenVideoAd',
        iOS.toJSON(),
      );
    } else if (Platform.isAndroid && android != null) {
      result = await _methodChannel.invokeMapMethod(
        'loadFullscreenVideoAd',
        android.toJSON(),
      );
    }
    return PangleResult.fromJson(result);
  }
}
