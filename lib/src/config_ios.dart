import 'package:flutter/foundation.dart';

import 'constant.dart';

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
  });

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

  /// The splash ad config for iOS
  ///
  /// [slotId] The unique identifier of splash ad.
  /// [tolerateTimeout] optional. Maximum allowable load timeout, default 3s, unit s.
  /// [hideSkipButton] optional. Whether hide skip button, default NO. If you hide the skip button, you need to customize the countdown.
  IOSSplashConfig({
    @required this.slotId,
    this.tolerateTimeout,
    this.hideSkipButton,
  });

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'tolerateTimeout': tolerateTimeout,
      'hideSkipButton': hideSkipButton,
    };
  }
}

class IOSRewardedVideoConfig {
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
  IOSRewardedVideoConfig({
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

class IOSBannerAdConfig {
  final String slotId;
  final PangleImgSize imgSize;

  final int count;

  /// The feed ad config for iOS
  ///
  /// [slotId] required. The unique identifier of a feed ad.
  /// [imgSize] required. Image size.
  IOSBannerAdConfig({
    @required this.slotId,
    this.imgSize = PangleImgSize.banner600_150,
    this.count,
  });

  /// Convert config to json
  Map<String, dynamic> toJSON() {
    return {
      'slotId': slotId,
      'imgSize': imgSize.index,
    };
  }
}

class IOSFeedAdConfig {
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
  IOSFeedAdConfig({
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
