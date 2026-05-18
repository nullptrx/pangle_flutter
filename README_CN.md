<!--<div align="center"><img src="https://repository-images.githubusercontent.com/283126613/361b7272-24cf-4b91-b6c4-ded2956210b4"/></div>-->

> 感谢 [JetBrains](https://jb.gg/OpenSource) 提供的非商业开源开发授权。

[English](README.md) | 中文

# <div align="center">穿山甲 Flutter SDK</div>

<div align="center"><code>pangle_flutter</code> 是一款集成了字节跳动穿山甲 Android 和 iOS SDK 的 Flutter 插件。</div>
<br>

<div align="center">
  <a href="https://flutter.io">
    <img src="https://img.shields.io/badge/Platform-Flutter-yellow.svg" alt="Platform" />
  </a>
  <a href="https://pub.dartlang.org/packages/pangle_flutter">
    <img src="https://img.shields.io/pub/v/pangle_flutter.svg" alt="Pub Package" />
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License: MIT" />
  </a>
</div><br>

## 目录

- [版本迁移](#版本迁移)
- [SDK 版本](#sdk-版本)
- [官方文档](#官方文档)
- [参数文档](#参数文档)
- [集成步骤](#集成步骤)
- [使用说明](#使用说明)
  - [1. 初始化](#1-初始化)
  - [2. 开屏广告](#2-开屏广告)
  - [3. 激励视频广告](#3-激励视频广告)
  - [4. 全屏视频广告](#4-全屏视频广告)
  - [5. Banner 广告](#5-banner-广告)
  - [6. 信息流广告](#6-信息流广告)
  - [7. 插屏广告](#7-插屏广告)
  - [8. 可点击区域（iOS）](#8-可点击区域ios)
  - [9. Draw 竖版视频广告](#9-draw-竖版视频广告)
  - [10. Stream 自定义播放广告](#10-stream-自定义播放广告)
  - [11. EcMall 电商广告](#11-ecmall-电商广告)
  - [12. 信息流图标广告](#12-信息流图标广告)
  - [13. 半全屏开屏广告（Android）](#13-半全屏开屏广告android)
- [贡献](#贡献)
- [赞助](#赞助)

原生平台示例：
- [Android Demo](https://github.com/bytedance/pangle-sdk-demo)
- [iOS Demo](https://github.com/bytedance/Bytedance-UnionAD)

---

## 版本迁移

### 2.x → 3.0

- **`SplashView` 错误回调拆分为两个**，不再共用同一个 `onError`：
  - `onError` — 广告**加载失败**时触发（网络错误、无填充等）
  - `onRenderFail` — 广告加载成功后**渲染失败**时触发（模板渲染异常）
  - 如果之前用 `onError` 捕获所有开屏错误，请额外添加 `onRenderFail` 来处理渲染失败的情况。
- **iOS 可点击区域语义变更**：`addTouchableBounds` / `clearTouchableBounds` 现在直接限制原生广告 View 的可点击区域。列表为空时（默认），所有触摸事件正常传递给原生 View；列表非空时，仅列表范围内的触摸事件会传递。旧方案依赖检测 `FlutterOverlayView` 来触发拦截，该机制在 Flutter 3+ TLHC 渲染模式下已失效。
- `BannerView` 和 `FeedView` 现在根据 `expressSize` 自动约束比例，无需外层手动套 `AspectRatio` 或指定高度。`SplashView` 仍需包裹在有明确尺寸约束的 Widget 中（如 `Container`、`SizedBox`、`Expanded`）。
- 点击广告右上角 ✕ 按钮不再自动移除 View，需在 `onClose` 回调中手动处理。

---

## SDK 版本

SDK 已作为内部依赖集成，无需手动引入。如需替换版本，请 fork 本项目并修改依赖声明。

- [[Android] 5.0+](https://www.pangle.cn/union/media/union/download/log?id=4)
- [[iOS] 5.0+](https://www.pangle.cn/union/media/union/download/log?id=16)

---

## 官方文档

- [穿山甲 Android SDK 文档](https://www.pangle.cn/union/media/union/download/detail?id=4&osType=android)
- [穿山甲 iOS SDK 文档](https://www.pangle.cn/union/media/union/download/detail?id=16&osType=ios)

---

## 参数文档

各配置类的完整参数说明见 [DOC_PROPERTY.md](DOC_PROPERTY.md)。

---

## 范例截图

<img src="https://raw.githubusercontent.com/nullptrX/assets/master/images/20210322143743.gif" width="30%"/>

---

## 集成步骤

### 1. 添加 yaml 依赖

```yaml
dependencies:
  pangle_flutter: latest
```

### 2. 平台配置

Android Manifest 修改及 iOS Info.plist / CocoaPods 配置请参见 [SETUP.md](SETUP.md)。

**iOS 说明：** 本插件默认依赖 `Ads-CN` pod，面向国内流量无需额外配置。

**纯 OC 项目（iOS）：** 在项目中创建任意一个 Swift 文件，根据 Xcode 提示选择 *Create Bridging Header*，否则 Swift 插件无法正常工作。

<img src="https://github.com/nullptrX/assets/raw/static/pangle_flutter/images/oc2swift.png" alt="OC 导入 Swift 模块" width="500" />

---

## 使用说明

### 1. 初始化

```dart
import 'package:pangle_flutter/pangle_flutter.dart';

// 若在 runApp 之前初始化，需加入此行
WidgetsFlutterBinding.ensureInitialized();

await pangle.init(
  iOS: IOSConfig(appId: kAppId),
  android: AndroidConfig(appId: kAppId),
);
```

---

### 2. 开屏广告

**全屏类型（非 PlatformView）**

```dart
await pangle.loadSplashAd(
  iOS: IOSSplashConfig(slotId: kSplashId, isExpress: false),
  android: AndroidSplashConfig(slotId: kSplashId, isExpress: false),
);
```

**自定义类型（PlatformView）**

```dart
SplashView(
  iOS: IOSSplashConfig(slotId: kSplashId, isExpress: false),
  android: AndroidSplashConfig(slotId: kSplashId, isExpress: false),
  onLoad: () {},                         // 广告加载成功
  onShow: () {},                         // 广告开始展示
  onClick: () {},                        // 广告被点击
  onClose: (type) {},                    // 广告关闭
  onError: (code, msg) {},               // 加载失败
  onRenderFail: (code, msg) {},          // 渲染失败（加载成功后）
);
```

---

### 3. 激励视频广告

使用 `RewardedAd.load()` + `ad.show()` 进行一次性加载展示，或使用 `RewardedAdPool` 预加载以减少用户等待时间。

**一次性加载/展示**

```dart
try {
  final ad = await RewardedAd.load(
    slotId: kRewardedVideoId,
    iOS: const IOSRewardedVideoConfig(slotId: kRewardedVideoId),
    android: AndroidRewardedVideoConfig(slotId: kRewardedVideoId),
  );
  // 能走到这里就说明加载成功
  final result = await ad.show(
    onEvent: (PangleAdEvent event) {
      switch (event) {
        case AdRewardEvent(:final verified):
          if (verified) grantReward();
        case AdClosedEvent():
          // 广告关闭
        default:
          break;
      }
    },
  );
} on AdLoadException catch (e) {
  debugPrint('加载失败: $e');
}
```

**预加载池（推荐，体验更好）**

```dart
// 应用启动时配置一次
await RewardedAdPool.instance.configure(
  slotId: kRewardedVideoId,
  poolSize: 2,        // 同时缓存 2 个广告
  autoRefill: true,   // 展示后自动补充
  iOS: const IOSRewardedVideoConfig(slotId: kRewardedVideoId),
  android: AndroidRewardedVideoConfig(slotId: kRewardedVideoId),
);

// 展示时判断是否准备好
if (await RewardedAdPool.instance.isReady(kRewardedVideoId)) {
  await RewardedAdPool.instance.show(
    slotId: kRewardedVideoId,
    onEvent: (event) {
      if (event case AdRewardEvent(:final verified) when verified) {
        grantReward();
      }
    },
  );
} else {
  // 广告还未准备好，提示用户稍后再试
}
```

---

### 4. 全屏视频广告

与激励视频广告模式相同，使用 `FullscreenAd` 一次性加载或 `FullscreenAdPool` 预加载。

**一次性加载/展示**

```dart
try {
  final ad = await FullscreenAd.load(
    slotId: kFullscreenVideoId,
    iOS: const IOSFullscreenVideoConfig(slotId: kFullscreenVideoId),
    android: AndroidFullscreenVideoConfig(slotId: kFullscreenVideoId),
  );
  await ad.show(
    onEvent: (event) {
      if (event is AdClosedEvent) Navigator.pop(context);
    },
  );
} on AdLoadException catch (e) {
  debugPrint('加载失败: $e');
}
```

**预加载池**

```dart
await FullscreenAdPool.instance.configure(
  slotId: kFullscreenVideoId,
  iOS: const IOSFullscreenVideoConfig(slotId: kFullscreenVideoId),
  android: AndroidFullscreenVideoConfig(slotId: kFullscreenVideoId),
);

if (await FullscreenAdPool.instance.isReady(kFullscreenVideoId)) {
  await FullscreenAdPool.instance.show(slotId: kFullscreenVideoId);
}
```

---

### 5. Banner 广告

> 点击 ✕ 按钮不再自动移除 View，请在相应回调中手动处理。

`BannerView` 根据 `expressSize` 自动应用比例约束，无需外层包裹。

```dart
BannerView(
  iOS: IOSBannerConfig(
    slotId: kBannerExpressId,
    expressSize: PangleExpressSize(width: 600, height: 260),
  ),
  android: AndroidBannerConfig(
    slotId: kBannerExpressId,
    expressSize: PangleExpressSize(width: 600, height: 260),
  ),
  onClick: () {},
  onError: (code, msg) {},
  onRenderFail: (code, msg) {},
)
```

---

### 6. 信息流广告

> 点击 ✕ 按钮不再自动移除条目，请在 `onDislike` 中手动处理。

**请求广告数据**

```dart
// 返回用于展示 FeedView 的广告 key 列表
PangleFeedAd feedAd = await pangle.loadFeedAd(
  iOS: IOSFeedConfig(slotId: kFeedId, count: 2),
  android: AndroidFeedConfig(slotId: kFeedId, count: 2),
);
// feedAd.data — 广告 ID 列表
```

**展示广告**

传入与 `loadFeedAd` 相同的 `expressSize`，`FeedView` 会自动约束比例。

```dart
final expressSize = PangleExpressSize(width: 375, height: 120);

// 加载
PangleAd feedAd = await pangle.loadFeedAd(
  iOS: IOSFeedConfig(slotId: kFeedId, expressSize: expressSize),
  android: AndroidFeedConfig(slotId: kFeedId, expressSize: expressSize),
);

// 渲染
FeedView(
  id: item.feedId,
  expressSize: expressSize,
  onDislike: (option, enforce) {
    pangle.removeFeedAd([item.feedId]);
    setState(() => items.removeAt(index));
  },
)
```

**释放广告缓存**

```dart
@override
void dispose() {
  pangle.removeFeedAd(feedIds);
  super.dispose();
}
```

---

### 7. 插屏广告

```dart
final result = await pangle.loadInterstitialAd(
  iOS: IOSInterstitialConfig(
    slotId: kInterstitialId,
    expressSize: PangleExpressSize(width: width, height: height),
  ),
  android: AndroidInterstitialConfig(slotId: kInterstitialId),
);
```

---

### 8. 可点击区域（iOS）

`addTouchableBounds` 用于限制原生广告 View 的可点击区域。当列表非空时，仅列表内的坐标范围可接收触摸事件，其余区域的触摸事件会穿透给下方的 Flutter Widget。

> **注意：** 此 API 仅适用于 iOS。Android 平台 View 的触摸路由由系统原生处理。

```dart
Container(
  height: 260,
  child: BannerView(
    iOS: IOSBannerConfig(
      slotId: kBannerId,
      expressSize: PangleExpressSize(width: 600, height: 260),
    ),
    android: AndroidBannerConfig(slotId: kBannerId),
    onBannerViewCreated: (BannerViewController controller) {
      // 仅允许指定屏幕坐标范围内的触摸传递给原生广告
      controller.addTouchableBound(Rect.fromLTWH(0, 0, 300, 260));

      // 清空限制（所有触摸均传递给原生广告）
      controller.clearTouchableBounds();
    },
  ),
),
```

**使用场景：** 有悬浮按钮与广告 View 重叠时，声明广告除按钮区域外的范围为可点击，使按钮仍可正常响应点击，广告其余区域也能正常接收点击事件。

```dart
_initTouchableBounds(BannerViewController controller) {
  if (!Platform.isIOS) return;

  final RenderBox buttonBox =
      _floatingButtonKey.currentContext!.findRenderObject() as RenderBox;
  final buttonBound = PangleHelper.fromRenderBox(buttonBox);

  // 允许广告中除按钮位置外的区域接收点击
  controller.addTouchableBound(Rect.fromLTWH(
    0,
    buttonBound.top,
    kPangleScreenWidth - buttonBound.width,
    buttonBound.height,
  ));
}
```

---

### 9. Draw 竖版视频广告

类似 TikTok 的竖向滑动全屏视频广告。批量加载 ID 后，在全屏 `PageView` 中逐一展示。

```dart
// 加载
final PangleDrawAd drawAd = await pangle.loadDrawAd(
  iOS: IOSDrawConfig(slotId: kDrawId, adCount: 3),
  android: AndroidDrawConfig(slotId: kDrawId, adCount: 2),
);

// 展示
PageView.builder(
  scrollDirection: Axis.vertical,
  itemCount: drawAd.data.length,
  itemBuilder: (context, i) => DrawView(
    id: drawAd.data[i],
    onClick: () {},
    onRenderFail: (code, msg) {},
  ),
);

// 释放
await pangle.removeDrawAd(drawAd.data);
```

---

### 10. Stream 自定义播放广告

返回视频 URL 及元数据，供自定义播放器使用，无需 SDK 渲染视图。

```dart
final PangleStreamAd streamAd = await pangle.loadStreamAd(
  iOS: IOSStreamConfig(slotId: kStreamId),
  android: AndroidStreamConfig(slotId: kStreamId, imgSize: PangleSize(width: 640, height: 320)),
);
for (final StreamAdItem item in streamAd.data) {
  // 使用 item.videoUrl 传入自定义播放器
  // item.title, item.imageUrl, item.videoDuration, item.description
}
```

---

### 11. EcMall 电商广告

以 PlatformView 形式渲染的电商原生广告，需包裹在有尺寸约束的 Widget 中。

```dart
SizedBox(
  width: 600,
  height: 257,
  child: EcMallView(
    slotId: kEcMallId,
    width: 600,
    height: 257,
    onClick: () {},
    onShow: () {},
    onError: (code, msg) {},
  ),
)
```

---

### 12. 信息流图标广告

适用于紧凑型列表或网格布局的图标尺寸广告，使用标准 `FeedView` 渲染。

```dart
final PangleAd iconAd = await pangle.loadFeedIconAd(
  android: AndroidFeedIconConfig(slotId: kFeedIconId, expressViewWidth: 160),
);
FeedView(id: iconAd.data.first)
```

---

### 13. 半全屏开屏广告（Android）

展示占屏幕约 4/5 高度的开屏广告，而非完整全屏。仅 Android 支持。

```dart
await pangle.loadSplashAd(
  android: AndroidSplashConfig(slotId: kSplashId, isHalfSize: true),
  iOS: IOSSplashConfig(slotId: kSplashId),
);
```

---

## 贡献

- 功能建议请提交 [PR](https://github.com/nullptrX/pangle_flutter/issues/new?template=feature_request.md)。
- 使用问题或 Bug 请提交 [issue](https://github.com/nullptrX/pangle_flutter/issues/new?template=bug_report.md)。

---

## 赞助

<a href="https://github.com/BokAugust">BokAugust</a>
