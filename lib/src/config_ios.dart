import 'package:flutter/foundation.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import 'constant.dart';
import 'extension.dart';

class IOSConfig {
  final String appId;
  final PangleLogLevel logLevel;
  final int coppa;
  final bool isPaidApp;

  /// Register the ad config for iOS
  ///
  /// [appId] the unique identifier of the App
  /// [logLevel] optional. default none
  /// [coppa] optional. Coppa 0 adult, 1 child
  /// [isPaidApp] optional. Set whether the app is a paid app, the default is a non-paid app.
  IOSConfig({
    @required this.appId,
    this.logLevel,
    this.coppa,
    this.isPaidApp,
  }) : assert(appId.isNotBlank);

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'appId': appId,
      'logLevel': logLevel?.index,
      'coppa': coppa,
      'isPaidApp': isPaidApp,
    };
  }
}

class IOSSplashConfig {
  final String slotId;
  final double tolerateTimeout;
  final bool hideSkipButton;
  final bool isExpress;
  final PangleExpressSize expressSize;

  /// The splash ad config for iOS
  ///
  /// [slotId] The unique identifier of splash ad.
  /// [tolerateTimeout] optional. Maximum allowable load timeout, default 3s, unit s.
  /// [hideSkipButton] optional. Whether hide skip button, default NO.
  ///    If you hide the skip button, you need to customize the countdown.
  /// [isExpress] optional. experimental. 个性化模板广告.
  /// [expressSize] optional. 模板宽高
  IOSSplashConfig({
    @required this.slotId,
    this.tolerateTimeout,
    this.hideSkipButton,
    this.isExpress = true,
    this.expressSize,
  }) : assert(slotId.isNotBlank);

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'tolerateTimeout': tolerateTimeout,
      'hideSkipButton': hideSkipButton,
      'isExpress': isExpress,
      'expressSize': expressSize?.toJson(),
    };
  }
}

class IOSRewardedVideoConfig {
  final String slotId;
  final String userId;
  final String rewardName;
  final int rewardAmount;
  final String extra;
  final PangleLoadingType loadingType;
  final bool isExpress;
  final PangleExpressSize expressSize;

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
  /// [loadingType] optional. 加载广告的类型，默认[PangleLoadingType.normal]
  /// [isExpress] optional. 个性化模板广告
  /// [expressSize] optional. 模板宽高，保留字段(iOS暂不支持该类型指定宽高)
  IOSRewardedVideoConfig({
    @required this.slotId,
    this.userId,
    this.rewardName,
    this.rewardAmount,
    this.extra,
    this.loadingType = PangleLoadingType.normal,
    this.isExpress = true,
    this.expressSize,
  }) : assert(slotId.isNotBlank);

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'userId': userId,
      'rewardName': rewardName,
      'rewardAmount': rewardAmount,
      'extra': extra,
      'loadingType': loadingType?.index,
      'isExpress': isExpress,
      'expressSize': expressSize?.toJson(),
    };
  }
}

class IOSBannerConfig {
  final String slotId;
  final PangleImgSize imgSize;
  final bool isExpress;
  final PangleExpressSize expressSize;
  final bool isUserInteractionEnabled;
  final int interval;

  /// The feed ad config for iOS
  ///
  /// [slotId] required. The unique identifier of a banner ad.
  /// [imgSize] required. Image size.
  /// [isExpress] optional. 个性化模板广告.
  /// [expressSize] optional. 模板宽高
  /// [interval] The carousel interval, in seconds, is set in the range of 30~120s,
  ///   and is passed during initialization. If it does not meet the requirements,
  ///   it will not be in carousel ad.
  IOSBannerConfig({
    @required this.slotId,
    this.imgSize = PangleImgSize.banner600_150,
    this.isExpress = true,
    this.expressSize,
    this.isUserInteractionEnabled = true,
    this.interval,
  })  : assert(slotId.isNotBlank),
        assert(!isExpress || (isExpress && expressSize != null));

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'imgSize': imgSize?.index,
      'isExpress': isExpress,
      'expressSize': expressSize?.toJson(),
      'isUserInteractionEnabled': isUserInteractionEnabled,
      'interval': interval,
    };
  }
}

class IOSFeedConfig {
  final String slotId;
  final PangleImgSize imgSize;

  final int count;
  final bool isSupportDeepLink;
  final bool isExpress;
  final PangleExpressSize expressSize;

  /// The feed ad config for iOS
  ///
  /// [slotId] required. The unique identifier of a feed ad.
  /// [imgSize] required. Image size.
  /// [count] It is recommended to request no more than 3 ads. The maximum is 10. default 3
  /// [isSupportDeepLink] optional. Whether to support deeplink.
  /// [isExpress] optional. 个性化模板广告.
  /// [expressSize] optional. 模板宽高.
  IOSFeedConfig({
    @required this.slotId,
    this.imgSize = PangleImgSize.feed690_388,
    this.count,
    this.isSupportDeepLink = true,
    this.isExpress = true,
    this.expressSize,
  })  : assert(slotId.isNotBlank),
        assert(!isExpress || (isExpress && expressSize != null));

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'count': count,
      'imgSize': imgSize?.index,
      'isSupportDeepLink': isSupportDeepLink,
      'isExpress': isExpress,
      'expressSize': expressSize?.toJson(),
    };
  }
}

class IOSInterstitialConfig {
  final String slotId;
  final PangleImgSize imgSize;
  final bool isExpress;
  final PangleExpressSize expressSize;

  /// The interstitial ad config for iOS
  ///
  /// [slotId] required. The unique identifier of a interstitial ad.
  /// [imgSize] required. Image size. 该宽高为你申请的广告位宽高，请根据实际情况赋值
  /// [isExpress] optional. 个性化模板广告.
  /// [expressSize] optional. 模板宽高.
  IOSInterstitialConfig({
    @required this.slotId,
    this.imgSize = PangleImgSize.interstitial600_400,
    this.isExpress = true,
    this.expressSize,
  })  : assert(slotId.isNotBlank),
        assert(!isExpress || (isExpress && expressSize != null));

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'imgSize': imgSize?.index,
      'isExpress': isExpress,
      'expressSize': expressSize?.toJson(),
    };
  }
}

class IOSFullscreenVideoConfig {
  final String slotId;
  final PangleLoadingType loadingType;
  final bool isExpress;
  final PangleExpressSize expressSize;

  /// The full screen video ad config for iOS
  ///
  /// [slotId] required. The unique identifier of a full screen video ad.
  /// [loadingType] optional. 加载广告的类型，默认[PangleLoadingType.normal]
  /// [isExpress] optional. 个性化模板广告
  /// [expressSize] optional. 模板宽高，保留字段(iOS暂不支持该类型指定宽高)
  IOSFullscreenVideoConfig({
    @required this.slotId,
    this.loadingType = PangleLoadingType.normal,
    this.isExpress = true,
    this.expressSize,
  }) : assert(slotId.isNotBlank);

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'loadingType': loadingType?.index,
      'isExpress': isExpress,
      'expressSize': expressSize?.toJson(),
    };
  }
}
