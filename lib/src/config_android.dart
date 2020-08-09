import 'package:flutter/foundation.dart';

import 'constant.dart';

class AndroidConfig {
  final String appId;
  final bool debug;
  final bool useTextureView;
  final AndroidTitleBarTheme titleBarTheme;
  final bool allowShowNotify;
  final bool allowShowPageWhenScreenLock;
  final int directDownloadNetworkType;
  final bool supportMultiProcess;
  final bool isPaidApp;

  /// Register the ad config for Android
  ///
  /// [appId] 必选参数，设置应用的AppId
  /// [debug] 测试阶段打开，可以通过日志排查问题，上线时去除该调用
  /// [allowShowNotify] 是否允许sdk展示通知栏提示
  /// [allowShowPageWhenScreenLock] 是否在锁屏场景支持展示广告落地页
  /// [supportMultiProcess] 可选参数，设置是否支持多进程：true支持、false不支持。默认为false不支持
  /// [directDownloadNetworkType] 可选参数，允许直接下载的网络状态集合
  /// [isPaidApp] 可选参数，设置是否为计费用户：true计费用户、false非计费用户。默认为false非计费用户。须征得用户同意才可传入该参数
  /// [useTextureView] 可选参数，设置是否使用texture播放视频：true使用、false不使用。默认为false不使用（使用的是surface）
  /// [titleBarTheme] 可选参数，设置落地页主题，默认为light
  /// TODO [keywords] 可选参数，设置用户画像的关键词列表 **不能超过为1000个字符**。须征得用户同意才可传入该参数
  /// TODO [isAsyncInit] 是否异步初始化sdk
  /// TODO [isCanUseLocation] 是否允许SDK主动使用地理位置信息。true可以获取，false禁止获取。默认为true
  /// TODO [defaultLocation] 当isCanUseLocation=false时，可传入地理位置信息，穿山甲sdk使用您传入的地理位置信息
  /// TODO [isCanUsePhoneState] 是否允许SDK主动使用手机硬件参数，如：imei。true可以使用，false禁止使用。默认为true
  /// TODO [defaultImei] 当isCanUsePhoneState=false时，可传入imei信息，穿山甲sdk使用您传入的imei信息
  /// TODO [isCanUseWifiState] 是否允许SDK主动使用ACCESS_WIFI_STATE权限。true可以使用，false禁止使用。默认为true
  /// TODO [isCanUseWriteExternal] 是否允许SDK主动使用WRITE_EXTERNAL_STORAGE权限。true可以使用，false禁止使用。默认为true
  AndroidConfig({
    @required this.appId,
    this.debug,
    this.allowShowNotify,
    this.allowShowPageWhenScreenLock,
    this.supportMultiProcess,
    this.directDownloadNetworkType = AndroidDirectDownloadNetworkType.kWiFi,
    this.isPaidApp,
    this.useTextureView,
    this.titleBarTheme = AndroidTitleBarTheme.light,
  });

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'appId': appId,
      'debug': debug,
      'allowShowNotify': allowShowNotify,
      'allowShowPageWhenScreenLock': allowShowPageWhenScreenLock,
      'supportMultiProcess': supportMultiProcess,
      'directDownloadNetworkType': directDownloadNetworkType,
      'paid': isPaidApp,
      'useTextureView': useTextureView,
      'titleBarTheme': titleBarTheme?.index,
    };
  }
}

class AndroidSplashConfig {
  final String slotId;
  final double tolerateTimeout;
  final bool hideSkipButton;
  final bool isExpress;

  /// The splash ad config for Android
  ///
  /// [slotId] The unique identifier of splash ad.
  /// [tolerateTimeout] optional. Maximum allowable load timeout, default 3s, unit s.
  /// [hideSkipButton] optional. Whether hide skip button, default NO. If you hide the skip button, you need to customize the countdown.
  /// [isExpress] optional. experimental. 个性化模板广告
  AndroidSplashConfig({
    @required this.slotId,
    this.tolerateTimeout,
    this.hideSkipButton,
    this.isExpress,
  });

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'tolerateTimeout': tolerateTimeout,
      'hideSkipButton': hideSkipButton,
      'isExpress': isExpress,
    };
  }
}

class AndroidRewardedVideoConfig {
  final String slotId;
  final String userId;
  final String rewardName;
  final int rewardAmount;
  final String extra;

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
  AndroidRewardedVideoConfig({
    @required this.slotId,
    this.userId,
    this.rewardName,
    this.rewardAmount,
    this.extra,
  });

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'userId': userId,
      'rewardName': rewardName,
      'rewardAmount': rewardAmount,
      'extra': extra,
    };
  }
}

class AndroidBannerAdConfig {
  final String slotId;
  final PangleImgSize imgSize;
  final bool isSupportDeepLink;

  /// The feed ad config for Android
  ///
  /// [slotId] required. The unique identifier of a feed ad.
  /// [imgSize] required. Image size.
  /// [isSupportDeepLink] optional. Whether to support deeplink.
  AndroidBannerAdConfig({
    @required this.slotId,
    this.imgSize = PangleImgSize.banner600_150,
    this.isSupportDeepLink,
  });

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'imgSize': imgSize.index,
      'isSupportDeepLink': isSupportDeepLink,
    };
  }
}

class AndroidFeedAdConfig {
  final String slotId;
  final PangleImgSize imgSize;

  final String tag;
  final int count;
  final bool isSupportDeepLink;

  /// The feed ad config for iOS
  ///
  /// [slotId] required. The unique identifier of a feed ad.
  /// [imgSize] required. Image size.
  /// [tag] optional. experimental. Mark it.
  /// [count] It is recommended to request no more than 3 ads. The maximum is 10. default 3
  /// [isSupportDeepLink] optional. Whether to support deeplink.
  AndroidFeedAdConfig({
    @required this.slotId,
    this.imgSize = PangleImgSize.feed690_388,
    this.tag,
    this.count,
    this.isSupportDeepLink,
  });

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'tag': tag,
      'count': count,
      'imgSize': imgSize.index,
      'isSupportDeepLink': isSupportDeepLink,
    };
  }
}
