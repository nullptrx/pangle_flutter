import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pangle_flutter/src/model.dart';

import 'config_android.dart';
import 'config_ios.dart';

final pangle = PanglePlugin._();

/// Pangle Ad Plugin
class PanglePlugin {
  static const MethodChannel _methodChannel = const MethodChannel('nullptrx.github.io/pangle');

  PanglePlugin._() {
    _methodChannel.setMethodCallHandler((call) => _handleMethod(call));
  }

  _handleMethod(MethodCall call) {}

  /// Request permissions
  /// 穿山甲SDK不强制获取权限，即使没有获取可选权限SDK也能正常运行；获取权限将帮助穿山甲优化投放广告精准度和用户的交互体验，提高eCPM。
  ///
  /// No effect on `iOS`, who does not allow this type of functionality.
  Future<Null> requestPermissionIfNecessary() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod('requestPermissionIfNecessary');
    }
  }

  /// Register the App key that’s already been applied before requesting an ad from TikTok Audience Network.
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
  Future<Null> loadSplashAd({
    IOSSplashConfig iOS,
    AndroidSplashConfig android,
  }) async {
    if (Platform.isIOS && iOS != null) {
      await _methodChannel.invokeMethod('loadSplashAd', iOS.toJSON());
    } else if (Platform.isAndroid && android != null) {
      await _methodChannel.invokeMethod('loadSplashAd', android.toJSON());
    }
  }

  /// Display video ad.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// return code & message
  Future<Map<String, dynamic>> loadRewardVideoAd({
    IOSRewardedVideoConfig iOS,
    AndroidRewardedVideoConfig android,
  }) async {
    if (Platform.isIOS && iOS != null) {
      return await _methodChannel.invokeMapMethod('loadRewardVideoAd', iOS.toJSON());
    } else if (Platform.isAndroid && android != null) {
      return await _methodChannel.invokeMapMethod('loadRewardVideoAd', android.toJSON());
    }
    return {};
  }

  /// Request feed ad data.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// return loaded ad count.
  Future<PangleFeedAd> loadFeedAd({
    IOSFeedAdConfig iOS,
    AndroidFeedAdConfig android,
  }) async {
    Map<dynamic, dynamic> ret;
    if (Platform.isIOS && iOS != null) {
      ret = await _methodChannel.invokeMapMethod('loadFeedAd', iOS.toJSON());
    } else if (Platform.isAndroid && android != null) {
      ret = await _methodChannel.invokeMapMethod('loadFeedAd', android.toJSON());
    }
    if (ret == null) {
      return PangleFeedAd.empty();
    }
    return PangleFeedAd.fromJsonMap(ret);
  }

  /// Request interstitial ad data.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  /// return loaded ad count.
  Future<Map<String, dynamic>> loadInterstitialAd({
    IOSInterstitialAdConfig iOS,
    AndroidInterstitialAdConfig android,
  }) async {
    throw UnimplementedError();
    if (Platform.isIOS && iOS != null) {
      return await _methodChannel.invokeMapMethod('loadInterstitialAd', iOS.toJSON());
    } else if (Platform.isAndroid && android != null) {
      return await _methodChannel.invokeMapMethod('loadInterstitialAd', android.toJSON());
    }
    return {};
  }
}
