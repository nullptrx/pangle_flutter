## 参数说明



### 初始化配置

```dart
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

/// Register the ad config for Android
///
/// [appId] 必选参数，设置应用的AppId
/// [debug] 测试阶段打开，可以通过日志排查问题，上线时去除该调用，默认false
/// [allowShowNotify] 是否允许sdk展示通知栏提示
/// [allowShowPageWhenScreenLock] 是否在锁屏场景支持展示广告落地页
/// [supportMultiProcess] 可选参数，设置是否支持多进程：true支持、false不支持。默认为false不支持
/// [directDownloadNetworkType] 可选参数，允许直接下载的网络状态集合，默认仅WiFi
/// [isPaidApp] 可选参数，设置是否为计费用户：true计费用户、false非计费用户。默认为false非计费用户。须征得用户同意才可传入该参数
/// [useTextureView] 可选参数，设置是否使用texture播放视频：true使用、false不使用。默认为false不使用（使用的是surface）
/// [titleBarTheme] 可选参数，设置落地页主题，默认为light
AndroidConfig({
  @required this.appId,
  this.debug,
  this.allowShowNotify,
  this.allowShowPageWhenScreenLock,
  this.supportMultiProcess,
  this.directDownloadNetworkType = AndroidDirectDownloadNetworkType.kWiFi /// 多个值，用 & 连接
  this.isPaidApp,
  this.useTextureView,
  this.titleBarTheme = AndroidTitleBarTheme.light,
});

```



### 开屏配置

```dart
/// The splash ad config for iOS
///
/// [slotId] The unique identifier of splash ad.
/// [tolerateTimeout] optional. Maximum allowable load timeout, default 3s, unit s.
/// [hideSkipButton] optional. Whether hide skip button, default NO.
///    If you hide the skip button, you need to customize the countdown.
///  [isExpress] 开屏无模板渲染，默认false
const IOSSplashConfig({
  @required this.slotId,
  this.tolerateTimeout,
  this.hideSkipButton,
  this.isExpress = false,
});

/// The splash ad config for Android
///
/// [slotId] The unique identifier of splash ad.
/// [tolerateTimeout] optional. Maximum allowable load timeout, default 3s, unit s.
/// [hideSkipButton] optional. Whether hide skip button, default NO. If you hide the skip button, you need to customize the countdown.
/// [isSupportDeepLink] optional. Whether to support deeplink. Default true.
/// [isExpress] 开屏广告无模板渲染，默认false
/// [expressSize] optional. 模板宽高
const AndroidSplashConfig({
  @required this.slotId,
  this.tolerateTimeout,
  this.hideSkipButton,
  this.isSupportDeepLink = true,
  this.isExpress = false,
  this.expressSize,
});
```



### 激励视频配置

```dart
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
const IOSRewardedVideoConfig({
  @required this.slotId,
  this.userId,
  this.rewardName,
  this.rewardAmount,
  this.extra,
  this.loadingType = PangleLoadingType.normal,
});

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
  @required this.slotId,
  this.userId,
  this.rewardName,
  this.rewardAmount,
  this.extra,
  this.isVertical = true,
  this.isSupportDeepLink = true,
  this.loadingType,
  this.expressSize,
});
```



### Banner配置

```dart
/// The feed ad config for iOS
///
/// [slotId] required. The unique identifier of a banner ad.
/// [expressSize] optional. 模板宽高
/// [isUserInteractionEnabled] 广告位是否可点击，true可以，false不可以
/// [interval] The carousel interval, in seconds, is set in the range of 30~120s,
///   and is passed during initialization. If it does not meet the requirements,
///   it will not be in carousel ad.
const IOSBannerConfig({
  @required this.slotId,
  @required this.expressSize,
  this.interval,
});

/// The feed ad config for Android
///
/// [slotId] required. The unique identifier of a banner ad.
/// [isSupportDeepLink] optional. Whether to support deeplink. default true.
/// [expressSize] optional. 模板宽高
/// [interval] The carousel interval, in seconds, is set in the range of 30~120s,
///   and is passed during initialization. If it does not meet the requirements,
///   it will not be in carousel ad.
const AndroidBannerConfig({
  @required this.slotId,
  @required this.expressSize,
  this.isSupportDeepLink = true,
  this.interval,
});
```



### 信息流配置

```dart
/// The feed ad config for iOS
///
/// [slotId] required. The unique identifier of a feed ad.
/// [count] It is recommended to request no more than 3 ads. The maximum is 10. default 3
/// [expressSize] optional. 模板宽高.
const IOSFeedConfig({
  @required this.slotId,
  @required this.expressSize,
  this.count,
});

/// The feed ad config for Android
///
/// [slotId] required. The unique identifier of a feed ad.
/// [count] It is recommended to request no more than 3 ads. The maximum is 10. default 3
/// [isSupportDeepLink] optional. Whether to support deeplink.
/// [isExpress] optional. 个性化模板广告
const AndroidFeedConfig({
  @required this.slotId,
  @required this.expressSize,
  this.count,
  this.isSupportDeepLink = true,
});
```

### 插屏广告

```dart
/// The interstitial ad config for iOS
///
/// [slotId] required. The unique identifier of a interstitial ad.
/// [expressSize] optional. 模板宽高.
const IOSInterstitialConfig({
  @required this.slotId,
  @required this.expressSize,
});


/// The interstitial ad config for Android
///
/// [slotId] required. The unique identifier of a interstitial ad.
/// [isSupportDeepLink] optional. Whether to support deep link. default true.
/// [expressSize] optional. 模板宽高
const AndroidInterstitialConfig({
  @required this.slotId,
  @required this.expressSize,
  this.isSupportDeepLink = true,
});
```



### 全屏视频广告

```dart
/// The full screen video ad config for iOS
///
/// [slotId] required. The unique identifier of a full screen video ad.
/// [loadingType] optional. 加载广告的类型，默认[PangleLoadingType.normal]
const IOSFullscreenVideoConfig({
  @required this.slotId,
  this.loadingType = PangleLoadingType.normal,
});


/// The full screen video ad config for Android
///
/// [slotId] required. The unique identifier of a full screen video ad.
/// [isSupportDeepLink] optional. Whether to support deeplink. default true.
/// [orientation] 设置期望视频播放的方向，默认[PangleOrientation.veritical]
/// [loadingType] optional. 加载广告的类型，默认[PangleLoadingType.normal]
/// [expressSize] optional. 模板宽高
const AndroidFullscreenVideoConfig({
  @required this.slotId,
  this.isSupportDeepLink = true,
  this.orientation = PangleOrientation.veritical,
  this.loadingType = PangleLoadingType.normal,
  this.expressSize,
});
```

