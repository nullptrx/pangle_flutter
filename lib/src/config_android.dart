import 'config.dart';
import 'constant.dart';
import 'model.dart';

class AndroidConfig implements Config {
  final String appId;
  final bool? debug;
  final bool? useTextureView;
  final AndroidTitleBarTheme titleBarTheme;
  final bool? allowShowNotify;
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
  final bool? useMediation;

  const AndroidConfig({
    required this.appId,
    this.debug,
    this.allowShowNotify,
    this.supportMultiProcess = false,
    this.directDownloadNetworkType = const [],
    this.isPaidApp,
    this.useTextureView = true,
    this.titleBarTheme = AndroidTitleBarTheme.light,
    this.isCanUseLocation,
    this.location,
    this.isCanUsePhoneState,
    this.devImei,
    this.isCanUseWifiState,
    this.isCanUseWriteExternal,
    this.devOaid,
    this.useMediation,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'appId': appId,
      'debug': debug,
      'allowShowNotify': allowShowNotify,
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
      'useMediation': useMediation,
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
  final bool isHalfSize;

  const AndroidSplashConfig({
    required this.slotId,
    this.tolerateTimeout,
    this.hideSkipButton,
    this.isSupportDeepLink = true,
    this.isExpress = false,
    this.expressSize,
    this.isHalfSize = false,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'tolerateTimeout': tolerateTimeout,
      'hideSkipButton': hideSkipButton,
      'isSupportDeepLink': isSupportDeepLink,
      'isExpress': isExpress,
      'expressSize': expressSize?.toJson(),
      'isHalfSize': isHalfSize,
    };
  }
}

class AndroidRewardedVideoConfig implements Config {
  final String slotId;
  final String? userId;
  final String? extra;
  final bool isVertical;
  final bool isSupportDeepLink;
  final PangleLoadingType? loadingType;
  final PangleExpressSize? expressSize;
  // 来自 Android demo RewardVideoActivity：setRewardAmount / setRewardName
  final int? rewardAmount;
  final String? rewardName;

  const AndroidRewardedVideoConfig({
    required this.slotId,
    this.userId,
    this.extra,
    this.isVertical = true,
    this.isSupportDeepLink = true,
    this.loadingType,
    this.expressSize,
    this.rewardAmount,
    this.rewardName,
  });

  AndroidRewardedVideoConfig copyWith({
    String? slotId,
    String? userId,
    String? extra,
    bool? isVertical,
    bool? isSupportDeepLink,
    PangleLoadingType? loadingType,
    PangleExpressSize? expressSize,
    int? rewardAmount,
    String? rewardName,
  }) {
    return AndroidRewardedVideoConfig(
      slotId: slotId ?? this.slotId,
      userId: userId ?? this.userId,
      extra: extra ?? this.extra,
      isVertical: isVertical ?? this.isVertical,
      isSupportDeepLink: isSupportDeepLink ?? this.isSupportDeepLink,
      loadingType: loadingType ?? this.loadingType,
      expressSize: expressSize ?? this.expressSize,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      rewardName: rewardName ?? this.rewardName,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    var expressSize = this.expressSize;
    expressSize ??= PangleExpressSize.aspectRatio9_16();

    return <String, dynamic>{
      'slotId': slotId,
      'userId': userId,
      'extra': extra,
      'isVertical': isVertical,
      'isSupportDeepLink': isSupportDeepLink,
      'loadingType': loadingType?.index,
      'expressSize': expressSize.toJson(),
      'rewardAmount': rewardAmount,
      'rewardName': rewardName,
    };
  }
}

class AndroidBannerConfig implements Config {
  final String slotId;
  final bool isSupportDeepLink;
  final PangleExpressSize expressSize;
  final int? interval;
  final PangleSize? imgSize;

  const AndroidBannerConfig({
    required this.slotId,
    required this.expressSize,
    this.isSupportDeepLink = true,
    this.interval,
    this.imgSize,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'isSupportDeepLink': isSupportDeepLink,
      'expressSize': expressSize.toJson(),
      'interval': interval,
      'imgSize': imgSize?.toJson(),
    };
  }
}

class AndroidFeedConfig implements Config {
  final String slotId;
  final int? count;
  final bool isSupportDeepLink;
  final PangleExpressSize expressSize;
  final PangleSize? imgSize;

  const AndroidFeedConfig({
    required this.slotId,
    required this.expressSize,
    this.count,
    this.isSupportDeepLink = true,
    this.imgSize,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'count': count,
      'isSupportDeepLink': isSupportDeepLink,
      'expressSize': expressSize.toJson(),
      'imgSize': imgSize?.toJson(),
    };
  }
}

// 来自 Android demo NativeExpressIconActivity：.supportIconStyle()
class AndroidFeedIconConfig implements Config {
  final String slotId;
  // setAdCount(1)
  final int adCount;
  // setExpressViewAcceptedSize(160, 0)
  final double expressViewWidth;
  final bool isSupportDeepLink;

  const AndroidFeedIconConfig({
    required this.slotId,
    this.adCount = 1,
    this.expressViewWidth = 160,
    this.isSupportDeepLink = true,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'adCount': adCount,
      'expressSize': {'width': expressViewWidth, 'height': 0.0},
      'supportIconStyle': true,
      'isSupportDeepLink': isSupportDeepLink,
    };
  }
}

class AndroidFullscreenVideoConfig implements Config {
  final String slotId;
  final bool isSupportDeepLink;
  final PangleOrientation orientation;
  final PangleLoadingType loadingType;
  final PangleExpressSize? expressSize;

  const AndroidFullscreenVideoConfig({
    required this.slotId,
    this.isSupportDeepLink = true,
    this.orientation = PangleOrientation.vertical,
    this.loadingType = PangleLoadingType.normal,
    this.expressSize,
  });

  AndroidFullscreenVideoConfig copyWith({
    String? slotId,
    bool? isSupportDeepLink,
    PangleOrientation? orientation,
    PangleLoadingType? loadingType,
    PangleExpressSize? expressSize,
  }) {
    return AndroidFullscreenVideoConfig(
      slotId: slotId ?? this.slotId,
      isSupportDeepLink: isSupportDeepLink ?? this.isSupportDeepLink,
      orientation: orientation ?? this.orientation,
      loadingType: loadingType ?? this.loadingType,
      expressSize: expressSize ?? this.expressSize,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    var expressSize = this.expressSize;
    expressSize ??= PangleExpressSize.aspectRatio9_16();
    return <String, dynamic>{
      'slotId': slotId,
      'isSupportDeepLink': isSupportDeepLink,
      'orientation': orientation.index,
      'loadingType': loadingType.index,
      'expressSize': expressSize.toJson(),
    };
  }
}

// 来自 Android demo DrawNativeExpressVideoActivity
class AndroidDrawConfig implements Config {
  final String slotId;
  // setExpressViewAcceptedSize，默认全屏
  final PangleExpressSize? expressSize;
  // setAdCount(2)
  final int adCount;
  final bool isSupportDeepLink;

  const AndroidDrawConfig({
    required this.slotId,
    this.expressSize,
    this.adCount = 2,
    this.isSupportDeepLink = true,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'expressSize': expressSize?.toJson(),
      'adCount': adCount,
      'isSupportDeepLink': isSupportDeepLink,
    };
  }
}

// 来自 Android demo StreamCustomPlayerActivity
class AndroidStreamConfig implements Config {
  final String slotId;
  // setImageAcceptedSize(640, 320)
  final PangleSize? imgSize;
  // setAdCount(1)
  final int adCount;
  final bool isSupportDeepLink;

  const AndroidStreamConfig({
    required this.slotId,
    this.imgSize,
    this.adCount = 1,
    this.isSupportDeepLink = true,
  });

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'slotId': slotId,
      'imgSize': imgSize?.toJson(),
      'adCount': adCount,
      'isSupportDeepLink': isSupportDeepLink,
    };
  }
}
