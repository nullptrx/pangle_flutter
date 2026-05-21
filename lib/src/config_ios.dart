import 'config.dart';
import 'constant.dart';
import 'model.dart';

class IOSConfig implements Config {
  final String appId;
  final PangleLogLevel? logLevel;
  final String? idfa;
  final bool? useMediation;

  const IOSConfig({
    required this.appId,
    this.logLevel,
    this.idfa,
    this.useMediation,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'appId': appId,
      'logLevel': logLevel?.index,
      'idfa': idfa,
      'useMediation': useMediation,
    };
  }
}

class IOSSplashConfig implements Config {
  final String slotId;
  final double? tolerateTimeout;
  final bool? hideSkipButton;
  final PangleExpressSize? expressSize;

  const IOSSplashConfig({
    required this.slotId,
    this.tolerateTimeout,
    this.hideSkipButton,
    this.expressSize,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'tolerateTimeout': tolerateTimeout,
      'hideSkipButton': hideSkipButton,
      'expressSize': expressSize?.toJson(),
    };
  }
}

class IOSRewardedVideoConfig implements Config {
  final String slotId;
  final String? userId;
  // 来自 iOS demo BUDExpressRewardedVideoViewController：model.rewardName = "金币"
  final String? rewardName;
  // 来自 iOS demo：model.rewardAmount = 300
  final int? rewardAmount;
  final String? extra;
  final PangleLoadingType loadingType;

  const IOSRewardedVideoConfig({
    required this.slotId,
    this.userId,
    this.rewardName,
    this.rewardAmount,
    this.extra,
    this.loadingType = PangleLoadingType.normal,
  });

  IOSRewardedVideoConfig copyWith({
    String? slotId,
    String? userId,
    String? rewardName,
    int? rewardAmount,
    String? extra,
    PangleLoadingType? loadingType,
  }) {
    return IOSRewardedVideoConfig(
      slotId: slotId ?? this.slotId,
      userId: userId ?? this.userId,
      rewardName: rewardName ?? this.rewardName,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      extra: extra ?? this.extra,
      loadingType: loadingType ?? this.loadingType,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'userId': userId,
      'rewardName': rewardName,
      'rewardAmount': rewardAmount,
      'extra': extra,
      'loadingType': loadingType.index,
    };
  }
}

class IOSBannerConfig implements Config {
  final String slotId;
  final PangleExpressSize expressSize;
  // 来自 iOS demo sizeDcit：轮播间隔秒数，0=不轮播，demo 中用 30
  final int? interval;

  const IOSBannerConfig({
    required this.slotId,
    required this.expressSize,
    this.interval,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'expressSize': expressSize.toJson(),
      'interval': interval,
    };
  }
}

class IOSFeedConfig implements Config {
  final String slotId;
  final int? count;
  final PangleExpressSize expressSize;
  final PangleSize? imgSize;
  // 来自 iOS demo BUDExpressFeedViewController：slot1.supportRenderControl = YES
  final bool? supportRenderControl;

  const IOSFeedConfig({
    required this.slotId,
    required this.expressSize,
    this.count,
    this.imgSize,
    this.supportRenderControl,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'count': count,
      'expressSize': expressSize.toJson(),
      'imgSize': imgSize?.toJson(),
      'supportRenderControl': supportRenderControl,
    };
  }
}

class IOSFullscreenVideoConfig implements Config {
  final String slotId;
  final PangleLoadingType loadingType;
  // 来自 iOS demo：切换插屏/全屏 slot 时使用
  final bool isInterstitialAd;

  const IOSFullscreenVideoConfig({
    required this.slotId,
    this.loadingType = PangleLoadingType.normal,
    this.isInterstitialAd = false,
  });

  IOSFullscreenVideoConfig copyWith({
    String? slotId,
    PangleLoadingType? loadingType,
    bool? isInterstitialAd,
  }) {
    return IOSFullscreenVideoConfig(
      slotId: slotId ?? this.slotId,
      loadingType: loadingType ?? this.loadingType,
      isInterstitialAd: isInterstitialAd ?? this.isInterstitialAd,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'loadingType': loadingType.index,
      'isInterstitialAd': isInterstitialAd,
    };
  }
}

// 来自 iOS demo BUDExpressDrawViewController
class IOSDrawConfig implements Config {
  final String slotId;
  // adSize = view.bounds.size（全屏）
  final PangleExpressSize? expressSize;
  // loadAdDataWithCount(3)
  final int adCount;

  const IOSDrawConfig({
    required this.slotId,
    this.expressSize,
    this.adCount = 3,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'expressSize': expressSize?.toJson(),
      'adCount': adCount,
    };
  }
}

// 来自 iOS demo BUDCustomVideoPlayerViewController
class IOSStreamConfig implements Config {
  final String slotId;
  // loadAdDataWithCount(1)
  final int adCount;

  const IOSStreamConfig({
    required this.slotId,
    this.adCount = 1,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'adCount': adCount,
    };
  }
}
