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

import 'config.dart';
import 'constant.dart';
import 'model.dart';

class AndroidConfig implements Config {
  final String appId;
  final bool? debug;
  final bool? async;
  final bool? useTextureView;
  final AndroidTitleBarTheme titleBarTheme;
  final bool? allowShowNotify;
  final bool? allowShowPageWhenScreenLock;
  final List<int> directDownloadNetworkType;
  final bool supportMultiProcess;
  final bool? isPaidApp;
  final bool? isCanUseLocation;
  final PangleLocation? location;
  final bool? isCanUsePhoneState;
  final String? devImei;
  final bool? isCanUseWifiState;
  final bool? isCanUseWriteExternal;
  final String? devOaid;

  /// Register the ad config for Android
  ///
  /// [appId] 必选参数，设置应用的AppId
  /// [debug] 测试阶段打开，可以通过日志排查问题，上线时去除该调用
  /// [async] 是否异步初始化
  /// [allowShowNotify] 是否允许sdk展示通知栏提示
  /// [allowShowPageWhenScreenLock] 是否在锁屏场景支持展示广告落地页
  /// [supportMultiProcess] 可选参数，设置是否支持多进程：true支持、false不支持。默认为false不支持
  /// [directDownloadNetworkType] （仅国内）可选参数，允许直接下载的网络状态集合
  /// [isPaidApp] 可选参数，设置是否为计费用户：true计费用户、false非计费用户。默认为false非计费用户。须征得用户同意才可传入该参数
  /// [useTextureView] 可选参数，设置是否使用texture播放视频：true使用、false不使用。默认为false不使用（使用的是surface）
  /// [titleBarTheme] 可选参数，设置落地页主题，默认为light
  /// TODO [keywords] 可选参数，设置用户画像的关键词列表 **不能超过为1000个字符**。须征得用户同意才可传入该参数
  /// [isCanUseLocation] （仅国内）是否允许SDK主动使用地理位置信息。true可以获取，false禁止获取。默认为true
  /// [location] （仅国内）当isCanUseLocation=false时，可传入地理位置信息，穿山甲sdk使用您传入的地理位置信息
  /// [isCanUsePhoneState] （仅国内）是否允许SDK主动使用手机硬件参数，如：imei。true可以使用，false禁止使用。默认为true
  /// [devImei] （仅国内）当isCanUsePhoneState=false时，可传入imei信息，穿山甲sdk使用您传入的imei信息
  /// [isCanUseWifiState] （仅国内）是否允许SDK主动使用ACCESS_WIFI_STATE权限。true可以使用，false禁止使用。默认为true
  /// [isCanUseWriteExternal] （仅国内）是否允许SDK主动使用WRITE_EXTERNAL_STORAGE权限。true可以使用，false禁止使用。默认为true
  /// [devOaid] （仅国内）开发者可以传入oaid
  const AndroidConfig({
    required this.appId,
    this.debug,
    this.async,
    this.allowShowNotify,
    this.allowShowPageWhenScreenLock,
    this.supportMultiProcess = false,
    this.directDownloadNetworkType = const [],
    this.isPaidApp,
    this.useTextureView,
    this.titleBarTheme = AndroidTitleBarTheme.light,
    this.isCanUseLocation,
    this.location,
    this.isCanUsePhoneState,
    this.devImei,
    this.isCanUseWifiState,
    this.isCanUseWriteExternal,
    this.devOaid,
  });

  /// Convert config to json
  @override
  Map<String, dynamic> toJSON() {
    return {
      'appId': appId,
      'async': async,
      'debug': debug,
      'allowShowNotify': allowShowNotify,
      'allowShowPageWhenScreenLock': allowShowPageWhenScreenLock,
      'supportMultiProcess': supportMultiProcess,
      'directDownloadNetworkType': directDownloadNetworkType,
      'paid': isPaidApp,
      'useTextureView': useTextureView,
      'titleBarTheme': titleBarTheme.index,
      'isCanUseLocation': isCanUseLocation,
      'location': location?.toJson(),
      'isCanUsePhoneState': isCanUsePhoneState,
      'devImei': devImei,
      'isCanUseWifiState': isCanUseWifiState,
      'isCanUseWriteExternal': isCanUseWriteExternal,
      'devOaid': devOaid,
    };
  }
}

class AndroidSplashConfig implements Config {
  final String slotId;
  final double? tolerateTimeout;
  final bool? hideSkipButton;
  final bool isExpress;
  final bool isSupportDeepLink;
  final PangleExpressSize? expressSize;

  /// The splash ad config for Android
  ///
  /// [slotId] The unique identifier of splash ad.
  /// [tolerateTimeout] optional. Maximum allowable load timeout, default 3s, unit s.
  /// [hideSkipButton] optional. Whether hide skip button, default NO. If you hide the skip button, you need to customize the countdown.
  /// [isSupportDeepLink] optional. Whether to support deeplink. Default true.
  /// [isExpress] 开屏广告无模板渲染，默认false
  /// [expressSize] optional. 模板宽高
  const AndroidSplashConfig({
    required this.slotId,
    this.tolerateTimeout,
    this.hideSkipButton,
    this.isSupportDeepLink = true,
    this.isExpress = false,
    this.expressSize,
  });

  /// Convert config to json
  @override
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'tolerateTimeout': tolerateTimeout,
      'hideSkipButton': hideSkipButton,
      'isSupportDeepLink': isSupportDeepLink,
      'isExpress': isExpress,
      'expressSize': expressSize?.toJson(),
    };
  }
}

class AndroidRewardedVideoConfig implements Config {
  final String slotId;
  final String? userId;
  final String? rewardName;
  final int? rewardAmount;
  final String? extra;
  final bool isVertical;
  final bool isSupportDeepLink;
  final PangleLoadingType? loadingType;
  final PangleExpressSize? expressSize;

  /// The rewarded video ad config for Android
  ///
  /// [slotId] The unique identifier of rewarded video ad.
  /// [userId] required.
  //   Third-party game user_id identity.
  //   Mainly used in the reward issuance, it is the callback pass-through parameter from server-to-server.
  //   It is the unique identifier of each user.
  //   In the non-server callback mode, it will also be pass-through when the video is finished playing.
  //   Only the string can be passed in this case, not nil.
  /// [rewardName] optional. reward name.
  /// [rewardAmount] optional. number of rewards.
  /// [extra] optional. serialized string.
  /// [isVertical] optional. Whether video is vertical orientation. Vertical, if true. Otherwise, horizontal.
  /// [isSupportDeepLink] optional. Whether to support deeplink. default true.
  /// [loadingType] optional. 加载广告的类型，默认[PangleLoadingType.normal]
  /// [expressSize] optional. 模板宽高
  const AndroidRewardedVideoConfig({
    required this.slotId,
    this.userId,
    this.rewardName,
    this.rewardAmount,
    this.extra,
    this.isVertical = true,
    this.isSupportDeepLink = true,
    this.loadingType,
    this.expressSize,
  });

  /// Convert config to json
  @override
  Map<String, dynamic> toJSON() {
    var expressSize = this.expressSize;
    if (expressSize == null) {
      expressSize = PangleExpressSize.aspectRatio9_16();
    }

    return {
      'slotId': slotId,
      'userId': userId,
      'rewardName': rewardName,
      'rewardAmount': rewardAmount,
      'extra': extra,
      'isVertical': isVertical,
      'isSupportDeepLink': isSupportDeepLink,
      'loadingType': loadingType?.index,
      'expressSize': expressSize.toJson(),
    };
  }
}

class AndroidBannerConfig implements Config {
  final String slotId;
  final bool isSupportDeepLink;
  final PangleExpressSize expressSize;
  final int? interval;

  /// The feed ad config for Android
  ///
  /// [slotId] required. The unique identifier of a banner ad.
  /// [isSupportDeepLink] optional. Whether to support deeplink. default true.
  /// [expressSize] optional. 模板宽高
  /// [interval] The carousel interval, in seconds, is set in the range of 30~120s,
  ///   and is passed during initialization. If it does not meet the requirements,
  ///   it will not be in carousel ad.
  const AndroidBannerConfig({
    required this.slotId,
    required this.expressSize,
    this.isSupportDeepLink = true,
    this.interval,
  });

  /// Convert config to json
  @override
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'isSupportDeepLink': isSupportDeepLink,
      'expressSize': expressSize.toJson(),
      'interval': interval,
    };
  }
}

class AndroidNativeBannerConfig implements Config {
  final String slotId;
  final bool isSupportDeepLink;
  final PangleSize size;
  final int? interval;

  /// The feed ad config for Android
  ///
  /// [slotId] required. The unique identifier of a banner ad.
  /// [isSupportDeepLink] optional. Whether to support deeplink. default true.
  /// [size] ads size
  /// [interval] The carousel interval, in seconds, is set in the range of 30~120s,
  ///   and is passed during initialization. If it does not meet the requirements,
  ///   it will not be in carousel ad.
  const AndroidNativeBannerConfig({
    required this.slotId,
    required this.size,
    this.isSupportDeepLink = true,
    this.interval,
  });

  /// Convert config to json
  @override
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'isSupportDeepLink': isSupportDeepLink,
      'size': size.toJson(),
      'interval': interval,
    };
  }
}

class AndroidFeedConfig implements Config {
  final String slotId;
  final int? count;
  final bool isSupportDeepLink;
  final PangleExpressSize expressSize;

  /// The feed ad config for Android
  ///
  /// [slotId] required. The unique identifier of a feed ad.
  /// [count] It is recommended to request no more than 3 ads. The maximum is 10. default 3
  /// [isSupportDeepLink] optional. Whether to support deeplink.
  /// [isExpress] optional. 个性化模板广告
  const AndroidFeedConfig({
    required this.slotId,
    required this.expressSize,
    this.count,
    this.isSupportDeepLink = true,
  });

  /// Convert config to json
  @override
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'count': count,
      'isSupportDeepLink': isSupportDeepLink,
      'expressSize': expressSize.toJson(),
    };
  }
}

class AndroidInterstitialConfig implements Config {
  final String slotId;
  final bool isSupportDeepLink;
  final PangleExpressSize expressSize;

  /// The interstitial ad config for Android
  ///
  /// [slotId] required. The unique identifier of a interstitial ad.
  /// [isSupportDeepLink] optional. Whether to support deep link. default true.
  /// [expressSize] optional. 模板宽高
  const AndroidInterstitialConfig({
    required this.slotId,
    required this.expressSize,
    this.isSupportDeepLink = true,
  });

  /// Convert config to json
  @override
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'isSupportDeepLink': isSupportDeepLink,
      'expressSize': expressSize.toJson(),
    };
  }
}

class AndroidFullscreenVideoConfig implements Config {
  final String slotId;
  final bool isSupportDeepLink;
  final PangleOrientation orientation;
  final PangleLoadingType loadingType;
  final PangleExpressSize? expressSize;

  /// The full screen video ad config for Android
  ///
  /// [slotId] required. The unique identifier of a full screen video ad.
  /// [isSupportDeepLink] optional. Whether to support deeplink. default true.
  /// [orientation] 设置期望视频播放的方向，默认[PangleOrientation.veritical]
  /// [loadingType] optional. 加载广告的类型，默认[PangleLoadingType.normal]
  /// [expressSize] optional. 模板宽高
  const AndroidFullscreenVideoConfig({
    required this.slotId,
    this.isSupportDeepLink = true,
    this.orientation = PangleOrientation.veritical,
    this.loadingType = PangleLoadingType.normal,
    this.expressSize,
  });

  /// Convert config to json
  @override
  Map<String, dynamic> toJSON() {
    var expressSize = this.expressSize;
    if (expressSize == null) {
      expressSize = PangleExpressSize.aspectRatio9_16();
    }
    return {
      'slotId': slotId,
      'isSupportDeepLink': isSupportDeepLink,
      'orientation': orientation.index,
      'loadingType': loadingType.index,
      'expressSize': expressSize.toJson(),
    };
  }
}
