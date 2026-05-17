[English](#english) | [中文](#中文)

---

## English

### Initialization

```dart
/// iOS initialization config
///
/// [appId]     Required. The unique App identifier issued by Pangle.
/// [logLevel]  Optional. Log verbosity. Default: none.
/// [coppa]     Optional. COPPA flag. 0 = adult audience, 1 = child audience.
IOSConfig({
  required this.appId,
  this.logLevel,
  this.coppa,
});

/// Android initialization config
///
/// [appId]                      Required. The unique App identifier issued by Pangle.
/// [debug]                      Optional. Enable verbose logging during development. Default: false. Remove before release.
/// [allowShowNotify]            Optional. Allow the SDK to show notification-bar prompts.
/// [supportMultiProcess]        Optional. Enable multi-process support. Default: false.
/// [directDownloadNetworkType]  Optional. Network types that allow direct (in-app) downloads. Default: Wi-Fi only.
/// [isPaidApp]                  Optional. Mark the app as a paid app. Requires user consent. Default: false.
/// [useTextureView]             Optional. Use TextureView instead of SurfaceView for video rendering. Default: false.
/// [titleBarTheme]              Optional. Landing-page title-bar theme. Default: light.
AndroidConfig({
  required this.appId,
  this.debug,
  this.allowShowNotify,
  this.supportMultiProcess,
  this.directDownloadNetworkType = AndroidDirectDownloadNetworkType.kWiFi,
  this.isPaidApp,
  this.useTextureView,
  this.titleBarTheme = AndroidTitleBarTheme.light,
});
```

---

### Splash Ad

```dart
/// iOS splash ad config
///
/// [slotId]          Required. The ad slot identifier.
/// [tolerateTimeout] Optional. Maximum load timeout in seconds. Default: 3s.
/// [hideSkipButton]  Optional. Hide the built-in skip button. If true, implement your own countdown UI. Default: false.
/// [isExpress]       Optional. Use template rendering (express). Default: false.
IOSSplashConfig({
  required this.slotId,
  this.tolerateTimeout,
  this.hideSkipButton,
  this.isExpress = false,
});

/// Android splash ad config
///
/// [slotId]           Required. The ad slot identifier.
/// [tolerateTimeout]  Optional. Maximum load timeout in seconds. Default: 3s.
/// [hideSkipButton]   Optional. Hide the built-in skip button. If true, implement your own countdown UI. Default: false.
/// [isSupportDeepLink] Optional. Enable deep-link support. Default: true.
/// [isExpress]        Optional. Use template rendering (express). Default: false.
/// [expressSize]      Optional. Template ad size (width × height).
/// [isHalfSize]       Optional. Show a half-screen splash (~4/5 screen height) instead of full-screen. Android only. Default: false.
AndroidSplashConfig({
  required this.slotId,
  this.tolerateTimeout,
  this.hideSkipButton,
  this.isSupportDeepLink = true,
  this.isExpress = false,
  this.expressSize,
  this.isHalfSize = false,
});
```

---

### Rewarded Video Ad

```dart
/// iOS rewarded video ad config
///
/// [slotId]      Required. The ad slot identifier.
/// [userId]      Optional. Your server's user identifier, passed through in server-to-server reward callbacks.
/// [rewardName]  Optional. Custom reward name.
/// [rewardAmount] Optional. Custom reward amount.
/// [extra]       Optional. Arbitrary extra data serialized as a string.
/// [loadingType] Optional. Ad loading strategy. Default: PangleLoadingType.normal.
IOSRewardedVideoConfig({
  required this.slotId,
  this.userId,
  this.rewardName,
  this.rewardAmount,
  this.extra,
  this.loadingType = PangleLoadingType.normal,
});

/// Android rewarded video ad config
///
/// [slotId]           Required. The ad slot identifier.
/// [userId]           Optional. Your server's user identifier, passed through in server-to-server reward callbacks.
/// [rewardName]       Optional. Custom reward name.
/// [rewardAmount]     Optional. Custom reward amount.
/// [extra]            Optional. Arbitrary extra data serialized as a string.
/// [isVertical]       Optional. Request a portrait-orientation video. Default: true.
/// [isSupportDeepLink] Optional. Enable deep-link support. Default: true.
/// [loadingType]      Optional. Ad loading strategy. Default: PangleLoadingType.normal.
/// [expressSize]      Optional. Template ad size (width × height).
AndroidRewardedVideoConfig({
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
```

---

### Banner Ad

```dart
/// iOS banner ad config
///
/// [slotId]      Required. The ad slot identifier.
/// [expressSize] Required. Template ad size (width × height). Must match the slot dimensions configured in the Pangle dashboard.
/// [interval]    Optional. Auto-refresh interval in seconds (range: 30–120s).
IOSBannerConfig({
  required this.slotId,
  required this.expressSize,
  this.interval,
});

/// Android banner ad config
///
/// [slotId]           Required. The ad slot identifier.
/// [expressSize]      Required. Template ad size (width × height). Must match the slot dimensions configured in the Pangle dashboard.
/// [isSupportDeepLink] Optional. Enable deep-link support. Default: true.
/// [interval]         Optional. Auto-refresh interval in seconds (range: 30–120s).
AndroidBannerConfig({
  required this.slotId,
  required this.expressSize,
  this.isSupportDeepLink = true,
  this.interval,
});
```

---

### Feed Ad

```dart
/// iOS feed ad config
///
/// [slotId]      Required. The ad slot identifier.
/// [expressSize] Required. Template ad size (width × height).
/// [count]       Optional. Number of ads to request. Recommended ≤ 3, maximum 10. Default: 3.
IOSFeedConfig({
  required this.slotId,
  required this.expressSize,
  this.count,
});

/// Android feed ad config
///
/// [slotId]           Required. The ad slot identifier.
/// [expressSize]      Required. Template ad size (width × height).
/// [count]            Optional. Number of ads to request. Recommended ≤ 3, maximum 10. Default: 3.
/// [isSupportDeepLink] Optional. Enable deep-link support. Default: true.
AndroidFeedConfig({
  required this.slotId,
  required this.expressSize,
  this.count,
  this.isSupportDeepLink = true,
});
```

---

### Interstitial Ad

```dart
/// iOS interstitial ad config
///
/// [slotId]      Required. The ad slot identifier.
/// [expressSize] Required. Template ad size (width × height). Must match the slot configured in the Pangle dashboard.
IOSInterstitialConfig({
  required this.slotId,
  required this.expressSize,
});

/// Android interstitial ad config
///
/// [slotId]           Required. The ad slot identifier.
/// [expressSize]      Required. Template ad size (width × height).
/// [isSupportDeepLink] Optional. Enable deep-link support. Default: true.
AndroidInterstitialConfig({
  required this.slotId,
  required this.expressSize,
  this.isSupportDeepLink = true,
});
```

---

### Fullscreen Video Ad

```dart
/// iOS fullscreen video ad config
///
/// [slotId]      Required. The ad slot identifier.
/// [loadingType] Optional. Ad loading strategy. Default: PangleLoadingType.normal.
IOSFullscreenVideoConfig({
  required this.slotId,
  this.loadingType = PangleLoadingType.normal,
});

/// Android fullscreen video ad config
///
/// [slotId]           Required. The ad slot identifier.
/// [isSupportDeepLink] Optional. Enable deep-link support. Default: true.
/// [orientation]      Optional. Preferred video playback orientation. Default: PangleOrientation.vertical.
/// [loadingType]      Optional. Ad loading strategy. Default: PangleLoadingType.normal.
/// [expressSize]      Optional. Template ad size (width × height).
AndroidFullscreenVideoConfig({
  required this.slotId,
  this.isSupportDeepLink = true,
  this.orientation = PangleOrientation.vertical,
  this.loadingType = PangleLoadingType.normal,
  this.expressSize,
});
```

---

## 中文

### 初始化配置

```dart
/// iOS 初始化配置
///
/// [appId]     必填。穿山甲分配的 App 唯一标识。
/// [logLevel]  可选。日志级别。默认不输出。
/// [coppa]     可选。COPPA 标记。0 = 成人用户，1 = 儿童用户。
IOSConfig({
  required this.appId,
  this.logLevel,
  this.coppa,
});

/// Android 初始化配置
///
/// [appId]                      必填。穿山甲分配的 App 唯一标识。
/// [debug]                      可选。开发阶段启用详细日志，上线前需移除。默认 false。
/// [allowShowNotify]            可选。是否允许 SDK 展示通知栏提示。
/// [supportMultiProcess]        可选。是否支持多进程。默认 false。
/// [directDownloadNetworkType]  可选。允许直接下载（应用内下载）的网络类型，默认仅 Wi-Fi。
/// [isPaidApp]                  可选。是否为计费用户，须用户授权后才可传入。默认 false。
/// [useTextureView]             可选。是否使用 TextureView 播放视频（替代 SurfaceView）。默认 false。
/// [titleBarTheme]              可选。落地页标题栏主题。默认 light。
AndroidConfig({
  required this.appId,
  this.debug,
  this.allowShowNotify,
  this.supportMultiProcess,
  this.directDownloadNetworkType = AndroidDirectDownloadNetworkType.kWiFi,
  this.isPaidApp,
  this.useTextureView,
  this.titleBarTheme = AndroidTitleBarTheme.light,
});
```

---

### 开屏广告配置

```dart
/// iOS 开屏广告配置
///
/// [slotId]          必填。广告位 ID。
/// [tolerateTimeout] 可选。最大加载超时时间（秒）。默认 3s。
/// [hideSkipButton]  可选。是否隐藏内置跳过按钮。隐藏时需自行实现倒计时 UI。默认 false。
/// [isExpress]       可选。是否使用模板渲染。默认 false。
IOSSplashConfig({
  required this.slotId,
  this.tolerateTimeout,
  this.hideSkipButton,
  this.isExpress = false,
});

/// Android 开屏广告配置
///
/// [slotId]           必填。广告位 ID。
/// [tolerateTimeout]  可选。最大加载超时时间（秒）。默认 3s。
/// [hideSkipButton]   可选。是否隐藏内置跳过按钮。默认 false。
/// [isSupportDeepLink] 可选。是否支持 DeepLink。默认 true。
/// [isExpress]        可选。是否使用模板渲染。默认 false。
/// [expressSize]      可选。模板渲染广告尺寸（宽 × 高）。
AndroidSplashConfig({
  required this.slotId,
  this.tolerateTimeout,
  this.hideSkipButton,
  this.isSupportDeepLink = true,
  this.isExpress = false,
  this.expressSize,
});
```

---

### 激励视频广告配置

```dart
/// iOS 激励视频广告配置
///
/// [slotId]       必填。广告位 ID。
/// [userId]       可选。业务侧用户 ID，用于服务端奖励回调透传，需为非空字符串。
/// [rewardName]   可选。自定义奖励名称。
/// [rewardAmount] 可选。自定义奖励数量。
/// [extra]        可选。额外透传数据（序列化字符串）。
/// [loadingType]  可选。广告加载策略。默认 PangleLoadingType.normal。
IOSRewardedVideoConfig({
  required this.slotId,
  this.userId,
  this.rewardName,
  this.rewardAmount,
  this.extra,
  this.loadingType = PangleLoadingType.normal,
});

/// Android 激励视频广告配置
///
/// [slotId]           必填。广告位 ID。
/// [userId]           可选。业务侧用户 ID，用于服务端奖励回调透传。
/// [rewardName]       可选。自定义奖励名称。
/// [rewardAmount]     可选。自定义奖励数量。
/// [extra]            可选。额外透传数据（序列化字符串）。
/// [isVertical]       可选。是否请求竖屏视频。默认 true。
/// [isSupportDeepLink] 可选。是否支持 DeepLink。默认 true。
/// [loadingType]      可选。广告加载策略。默认 PangleLoadingType.normal。
/// [expressSize]      可选。模板渲染广告尺寸（宽 × 高）。
AndroidRewardedVideoConfig({
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
```

---

### Banner 广告配置

```dart
/// iOS Banner 广告配置
///
/// [slotId]      必填。广告位 ID。
/// [expressSize] 必填。模板渲染尺寸（宽 × 高），需与穿山甲平台配置一致。
/// [interval]    可选。轮播间隔（秒），有效范围 30–120s。
IOSBannerConfig({
  required this.slotId,
  required this.expressSize,
  this.interval,
});

/// Android Banner 广告配置
///
/// [slotId]           必填。广告位 ID。
/// [expressSize]      必填。模板渲染尺寸（宽 × 高），需与穿山甲平台配置一致。
/// [isSupportDeepLink] 可选。是否支持 DeepLink。默认 true。
/// [interval]         可选。轮播间隔（秒），有效范围 30–120s。
AndroidBannerConfig({
  required this.slotId,
  required this.expressSize,
  this.isSupportDeepLink = true,
  this.interval,
});
```

---

### 信息流广告配置

```dart
/// iOS 信息流广告配置
///
/// [slotId]      必填。广告位 ID。
/// [expressSize] 必填。模板渲染尺寸（宽 × 高）。
/// [count]       可选。请求广告数量，建议不超过 3，最大 10。默认 3。
IOSFeedConfig({
  required this.slotId,
  required this.expressSize,
  this.count,
});

/// Android 信息流广告配置
///
/// [slotId]           必填。广告位 ID。
/// [expressSize]      必填。模板渲染尺寸（宽 × 高）。
/// [count]            可选。请求广告数量，建议不超过 3，最大 10。默认 3。
/// [isSupportDeepLink] 可选。是否支持 DeepLink。默认 true。
AndroidFeedConfig({
  required this.slotId,
  required this.expressSize,
  this.count,
  this.isSupportDeepLink = true,
});
```

---

### 插屏广告配置

```dart
/// iOS 插屏广告配置
///
/// [slotId]      必填。广告位 ID。
/// [expressSize] 必填。模板渲染尺寸（宽 × 高），需与穿山甲平台配置一致。
IOSInterstitialConfig({
  required this.slotId,
  required this.expressSize,
});

/// Android 插屏广告配置
///
/// [slotId]           必填。广告位 ID。
/// [expressSize]      必填。模板渲染尺寸（宽 × 高）。
/// [isSupportDeepLink] 可选。是否支持 DeepLink。默认 true。
AndroidInterstitialConfig({
  required this.slotId,
  required this.expressSize,
  this.isSupportDeepLink = true,
});
```

---

### 全屏视频广告配置

```dart
/// iOS 全屏视频广告配置
///
/// [slotId]      必填。广告位 ID。
/// [loadingType] 可选。广告加载策略。默认 PangleLoadingType.normal。
IOSFullscreenVideoConfig({
  required this.slotId,
  this.loadingType = PangleLoadingType.normal,
});

/// Android 全屏视频广告配置
///
/// [slotId]           必填。广告位 ID。
/// [isSupportDeepLink] 可选。是否支持 DeepLink。默认 true。
/// [orientation]      可选。期望视频播放方向。默认 PangleOrientation.vertical（竖屏）。
/// [loadingType]      可选。广告加载策略。默认 PangleLoadingType.normal。
/// [expressSize]      可选。模板渲染广告尺寸（宽 × 高）。
AndroidFullscreenVideoConfig({
  required this.slotId,
  this.isSupportDeepLink = true,
  this.orientation = PangleOrientation.vertical,
  this.loadingType = PangleLoadingType.normal,
  this.expressSize,
});
```

---

### Draw Ad

```dart
/// iOS draw ad config
///
/// [slotId]      Required. The ad slot identifier.
/// [expressSize] Optional. Template ad size. Defaults to full-screen bounds.
/// [adCount]     Optional. Number of ads to load. Default: 3.
IOSDrawConfig({
  required this.slotId,
  this.expressSize,
  this.adCount = 3,
});

/// Android draw ad config
///
/// [slotId]            Required. The ad slot identifier.
/// [expressSize]       Optional. Template ad size. Defaults to full-screen (MATCH_PARENT).
/// [adCount]           Optional. Number of ads to load. Default: 2.
/// [isSupportDeepLink] Optional. Enable deep-link support. Default: true.
AndroidDrawConfig({
  required this.slotId,
  this.expressSize,
  this.adCount = 2,
  this.isSupportDeepLink = true,
});
```

---

### Stream Ad

```dart
/// iOS stream ad config
///
/// [slotId]   Required. The ad slot identifier.
/// [adCount]  Optional. Number of ads to load. Default: 1.
IOSStreamConfig({
  required this.slotId,
  this.adCount = 1,
});

/// Android stream ad config
///
/// [slotId]            Required. The ad slot identifier.
/// [imgSize]           Optional. Cover image size hint (width × height). Recommended: PangleSize(width: 640, height: 320).
/// [adCount]           Optional. Number of ads to load. Default: 1.
/// [isSupportDeepLink] Optional. Enable deep-link support. Default: true.
AndroidStreamConfig({
  required this.slotId,
  this.imgSize,
  this.adCount = 1,
  this.isSupportDeepLink = true,
});
```

---

### Feed Icon Ad

```dart
/// Android feed icon ad config
///
/// [slotId]            Required. The ad slot identifier.
/// [adCount]           Optional. Number of ads to load. Default: 1.
/// [expressViewWidth]  Optional. Icon width in logical pixels. Default: 160.
/// [isSupportDeepLink] Optional. Enable deep-link support. Default: true.
AndroidFeedIconConfig({
  required this.slotId,
  this.adCount = 1,
  this.expressViewWidth = 160,
  this.isSupportDeepLink = true,
});
```

---

### Draw 广告配置

```dart
/// iOS Draw 广告配置
///
/// [slotId]      必填。广告位 ID。
/// [expressSize] 可选。模板渲染尺寸，默认全屏。
/// [adCount]     可选。加载广告数量。默认 3。
IOSDrawConfig({
  required this.slotId,
  this.expressSize,
  this.adCount = 3,
});

/// Android Draw 广告配置
///
/// [slotId]            必填。广告位 ID。
/// [expressSize]       可选。模板渲染尺寸，默认全屏（MATCH_PARENT）。
/// [adCount]           可选。加载广告数量。默认 2。
/// [isSupportDeepLink] 可选。是否支持 DeepLink。默认 true。
AndroidDrawConfig({
  required this.slotId,
  this.expressSize,
  this.adCount = 2,
  this.isSupportDeepLink = true,
});
```

---

### Stream 广告配置

```dart
/// iOS Stream 广告配置
///
/// [slotId]   必填。广告位 ID。
/// [adCount]  可选。加载广告数量。默认 1。
IOSStreamConfig({
  required this.slotId,
  this.adCount = 1,
});

/// Android Stream 广告配置
///
/// [slotId]            必填。广告位 ID。
/// [imgSize]           可选。封面图片尺寸（宽 × 高）。推荐：PangleSize(width: 640, height: 320)。
/// [adCount]           可选。加载广告数量。默认 1。
/// [isSupportDeepLink] 可选。是否支持 DeepLink。默认 true。
AndroidStreamConfig({
  required this.slotId,
  this.imgSize,
  this.adCount = 1,
  this.isSupportDeepLink = true,
});
```

---

### 信息流图标广告配置

```dart
/// Android 信息流图标广告配置
///
/// [slotId]            必填。广告位 ID。
/// [adCount]           可选。加载广告数量。默认 1。
/// [expressViewWidth]  可选。图标宽度（逻辑像素）。默认 160。
/// [isSupportDeepLink] 可选。是否支持 DeepLink。默认 true。
AndroidFeedIconConfig({
  required this.slotId,
  this.adCount = 1,
  this.expressViewWidth = 160,
  this.isSupportDeepLink = true,
});
```
