# Pangle Flutter Demo 复刻规划文档

## 核心原则

> **以 demo 功能为准，不兼容旧实现。**
>
> - 不考虑与现有 Flutter plugin 任何旧逻辑的兼容性
> - 凡是 demo 中没有用到的参数、属性、配置项、类，一律删除，不保留
> - 凡是旧实现与 demo 行为不一致的，以 demo 为准直接重写
> - 不做"保留旧接口同时新增"的过渡设计，直接替换
> - 代码只服务于 demo 中的功能场景，不为假想的未来需求做预留
> - **demo 中用到的每一个参数必须完整复刻到 Flutter plugin**：Android demo 的 `AdSlot.Builder` 参数、iOS demo 的 `BUAdSlot` / 各广告对象初始化参数，凡在 demo 中有赋值的，均需在对应的 Dart 配置类中体现，并在 Android/iOS plugin 中原样传递给原生 SDK，不得遗漏或简化

## 工作流规则（每次较大改动后必须执行）

完成任意一个模块后，按顺序执行：

1. **更新本文档** — 在对应步骤前标记 `✅`
2. **更新 memory `project_progress.md`** — 将对应行 ⬜ 改为 ✅
3. **git commit**，日志格式：

```
<模块名>：<一句话描述>

完成内容：
- <文件>：<做了什么>

参考来源：
- Android demo: <文件名>
- iOS demo: <文件名>

剩余工作（下一步）：
- [ ] <下一模块>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

## 目标

将 Android demo (`template/demo`) 的所有广告示例完整复刻到 Flutter example 中，功能对齐原生 demo，而非现有 Flutter 方案。之后根据 Flutter 实现和 `template/union_platform_iOS_7.6.0.3` 实现 iOS 插件。

执行顺序：`template/demo` → `Flutter example` → `Flutter plugin (Dart)` → `Android plugin` → `iOS plugin`

---

## 广告单元 ID 对照表

### 应用 ID
| 平台 | AppId |
|------|-------|
| Android | `5001121` |
| iOS | `5000546` |

### Android 广告位 ID（来自 template/demo）

| 广告类型 | 名称 | CodeId |
|----------|------|--------|
| 开屏-全屏 | 全屏开屏 | `801121648` |
| 开屏-半全屏 | 半全屏开屏 | `801121648` + `is_half_size=true` |
| 开屏-模板 | 模板开屏 | `801121974` |
| 开屏-横版模板 | 横版模板开屏 | `887631026` |
| 开屏-横版 | 横版开屏 | `887654027` |
| 开屏-小手 | 小手互动开屏 | `888041254` |
| 开屏-摇一摇 | 摇一摇开屏 | `888041256` |
| 开屏-扭一扭 | 扭一扭开屏 | `888041255` |
| 开屏-上滑 | 上滑开屏 | `888041257` |
| 激励视频-横屏 | 激励视频 | `901121430` |
| 激励视频-竖屏 | 激励视频 | `901121365` |
| 激励视频-模板横屏 | 模板激励视频 | `901121543` |
| 激励视频-模板竖屏 | 模板激励视频 | `901121593` |
| 全屏视频-横屏 | 全屏视频 | `901121184` |
| 全屏视频-竖屏 | 全屏视频 | `901121375` |
| 全屏视频-模板横屏 | 模板全屏视频 | `901121516` |
| 全屏视频-模板竖屏 | 模板全屏视频 | `901121073` |
| 新插屏-半屏横 | 新插屏半屏 | `947934020` |
| 新插屏-半屏竖 | 新插屏半屏 | `947793385` |
| 新插屏-全屏横 | 新插屏全屏 | `947934073` |
| 新插屏-全屏竖 | 新插屏全屏 | `947747681` |
| 原生 Banner | 原生Banner | `NativeBannerActivity` (无额外 ID 需看实现) |
| 模板 Banner | 模板Banner | `BannerExpressActivity` (需看实现) |
| 信息流-原生LV | 原生信息流ListView | `FeedListActivity` |
| 信息流-原生RV | 原生信息流RecyclerView | `FeedRecyclerActivity` |
| 信息流-模板 | 模板信息流 | `NativeExpressActivity` |
| 信息流-模板列表 | 模板信息流列表 | `NativeExpressListActivity` |
| 信息流-模板图标 | 模板信息流图标 | `NativeExpressIconActivity` |
| 信息流-电商Mall | 电商Mall | `NativeEcMallActivity` |
| Draw-原生 | 原生Draw视频 | `DrawNativeVideoActivity` |
| Draw-模板 | 模板Draw视频 | `DrawNativeExpressVideoActivity` |
| Stream-自定义 | 流媒体自定义播放 | `945593053` |
| 瀑布流 | 瀑布流 | `NativeWaterfallActivity` |

### iOS 广告位 ID（来自 template/union_platform_iOS_7.6.0.3/BUDSlotID.h）

| 广告类型 | 宏名 | SlotID |
|----------|------|--------|
| 开屏-模板 | `express_splash_ID` | `800546851` |
| 开屏-普通 | `normal_splash_ID` | `800546808` |
| 激励视频-竖屏 | `express_reward_ID_both` | `945113162` |
| 激励视频-横屏 | `express_reward_landscape_ID_both` | `945113163` |
| 全屏视频-竖屏 | `express_full_ID_both` | `945113164` |
| 全屏视频-横屏 | `express_full_landscape_ID_both` | `945113165` |
| 新插屏-全屏 | `express_new_interstitial_full` | `947866846` |
| 新插屏-半屏 | `express_new_interstitial_half` | `947877457` |
| Banner-模板 | `express_banner_ID` | `900546269` |
| Banner-原生 | `native_banner_ID` | `900546687` |
| 信息流-模板 | `express_feed_ID` | `945113159` |
| 信息流-模板视频 | `express_feed_video_ID` | `945294189` |
| 信息流-原生 | `native_feed_ID` | `900546910` |
| Draw-模板 | `express_draw_ID` | `900546881` |
| Draw-原生 | `native_draw_ID` | `900546588` |
| Stream-自定义 | `native_feed_custom_player_ID` | `900546910` |

---

## Demo 功能页面映射

以 Android demo 的菜单结构为基准：

```
MainActivity
├── 信息流广告 (FeedActivity)
│   ├── 原生信息流 ListView
│   ├── 原生信息流 RecyclerView
│   ├── 模板渲染信息流（单条）
│   ├── 模板渲染信息流列表
│   ├── 模板渲染信息流图标
│   └── 电商Mall
├── 竖版视频 Draw (DrawActivity)
│   ├── 原生 Draw 视频
│   └── 模板 Draw 视频
├── Banner 广告 (BannerActivity)
│   ├── 原生 Banner
│   └── 模板 Banner（多尺寸）
├── 开屏广告 (SplashMainActivity)
│   ├── 全屏开屏
│   ├── 半全屏开屏
│   ├── 模板开屏
│   ├── 横版模板开屏
│   ├── 横版开屏
│   ├── 小手互动开屏
│   ├── 摇一摇开屏
│   ├── 扭一扭开屏
│   └── 上滑开屏
├── 激励视频 (RewardActivity)
│   ├── 激励视频（横/竖屏）
│   └── 模板激励视频（横/竖屏）
├── 全屏视频/插屏 (FullScreenActivity + NewInteractionActivity)
│   ├── 全屏视频（横/竖屏）
│   ├── 模板全屏视频（横/竖屏）
│   ├── 新插屏-半屏（横/竖屏）
│   └── 新插屏-全屏（横/竖屏）
├── 流媒体自定义播放器 (StreamCustomPlayerActivity)
│   └── 自定义播放器播放 Stream 广告
└── 瀑布流 (NativeWaterfallActivity)
    └── 模板渲染瀑布流
```

---

## 实现计划（按模块顺序）

### Phase 1：Flutter Example（UI层，用接口占位）

#### 1.1 常量文件 `example/lib/page/constant.dart` 更新

补充所有 Android/iOS 广告位 ID 常量：
- Android: 所有上表中的 ID
- iOS: 所有上表中的 ID
- AppId: Android `5001121`, iOS `5000546`

#### 1.2 首页 `home_page.dart` 重构

对齐 Android `MainActivity`，改为：
- 显示 SDK 版本
- 8 个入口按钮（信息流/Draw/Banner/开屏/激励视频/全屏视频+插屏/流媒体/瀑布流）

#### 1.3 开屏广告页 `page/splash/splash_list_page.dart`

对齐 `SplashMainActivity`，9 个子入口，每个传入不同的 slotId + 参数。
调用 `pangle.loadSplashAd()`（现有接口已有）。

**新增 Widget**：`SplashView` 的 `isHalfSize` 参数支持（Android 独有）。

#### 1.4 激励视频页 `page/reward/reward_list_page.dart`

对齐 `RewardActivity` + `RewardVideoActivity`：
- 加载横屏/竖屏广告（两个按钮）
- 加载后展示
- 支持普通版和模板版

调用接口：`pangle.loadRewardedVideoAd()`（现有）

#### 1.5 全屏视频 + 新插屏页 `page/fullscreen/fullscreen_list_page.dart`

对齐 `FullScreenActivity` + `NewInteractionActivity` + `FullScreenVideoActivity`：
- 全屏视频（横/竖）
- 模板全屏视频（横/竖）
- 新插屏半屏（横/竖）
- 新插屏全屏（横/竖）
- 每种加载+展示各一个按钮

调用接口：`pangle.loadFullscreenVideoAd()`（现有）

#### 1.6 Banner 广告页 `page/banner/banner_list_page.dart`

对齐 `BannerActivity`：
- 原生 Banner（`NativeBannerView` Widget）
- 模板 Banner（`BannerView` Widget，多种尺寸）

**新增接口**（需要 plugin 实现）：`pangle.loadNativeBannerAd()` → 返回 id，配合 `NativeBannerView`。

#### 1.7 信息流广告页 `page/feed/feed_list_page.dart`

对齐 `FeedActivity`：
- 模板渲染信息流（单条，`FeedView`）——现有
- 模板渲染信息流列表（滚动列表中混入多条 `FeedView`）——现有基础扩展
- 模板渲染信息流图标——**新增**（请求 icon 尺寸）
- 电商Mall——**新增**（特殊布局）

原生信息流（非模板）对 Flutter 不适用（需自定义渲染），**暂不实现**，在 UI 上注明。

#### 1.8 Draw 竖版视频页 `page/draw/draw_list_page.dart`

对齐 `DrawActivity`：
- 模板 Draw 视频（`DrawView` / `FeedView` 竖版展示，全屏 PageView）

**新增接口**：`pangle.loadDrawAd()` 返回 id 列表，配合 `DrawView` Widget。
**新增 Widget**：`DrawView`（全屏竖版滑动，类 TikTok 样式）。

#### 1.9 流媒体自定义播放器页 `page/stream/stream_page.dart`

对齐 `StreamCustomPlayerActivity`：
- 加载 Stream 广告（codeId: 945593053 / iOS: 900546910）
- 展示（视频信息 + 简单 VideoPlayer 或 WebView）

**新增接口**：`pangle.loadStreamAd()` → 返回视频 URL + 素材信息。

#### 1.10 瀑布流页 `page/waterfall/waterfall_page.dart`

对齐 `NativeWaterfallActivity`：
- 模板渲染信息流，以 GridView 双列瀑布流展示
- 复用现有 `FeedView` Widget 即可

---

### Phase 2：Flutter Plugin Dart 层（接口定义 + 参数完整复刻）

在 `lib/src/` 中重写/新增。每个配置类的字段必须与原生 demo 的 `AdSlot.Builder` / `BUAdSlot` / 广告对象初始化参数一一对应。

---

#### 2.1 配置类参数完整清单

##### `AndroidSplashConfig` / `IOSSplashConfig`

Android（来自 `CSJSplashActivity`）：
```dart
class AndroidSplashConfig {
  final String slotId;             // setCodeId
  final double expressViewWidth;   // setExpressViewAcceptedSize width (dp) - 屏幕宽
  final double expressViewHeight;  // setExpressViewAcceptedSize height (dp) - 屏幕高或4/5
  final int imageWidth;            // setImageAcceptedSize width (px)
  final int imageHeight;           // setImageAcceptedSize height (px)
  final bool isHalfSize;           // 是否半全屏（高度=屏幕高*4/5）
  final int timeout;               // 加载超时 ms，默认3000
}
```

iOS（来自 `BUDSplashViewController`）：
```dart
class IOSSplashConfig {
  final String slotId;
  final double adWidth;            // adSize.width
  final double adHeight;           // adSize.height（半屏时=屏幕高-100）
  final bool supportCardView;      // splashAd.supportCardView = YES
  final double tolerateTimeout;    // splashAd.tolerateTimeout = 3.0
  final bool hideSkipButton;       // splashAd.hideSkipButton（自定义倒计时时使用）
}
```

##### `AndroidRewardedVideoConfig` / `IOSRewardedVideoConfig`

Android（来自 `RewardVideoActivity`）：
```dart
class AndroidRewardedVideoConfig {
  final String slotId;             // setCodeId
  final int adLoadType;            // setAdLoadType: 1=LOAD(实时), 2=PRELOAD(预请求)
  final int rewardAmount;          // setRewardAmount，默认123
  final String rewardName;         // setRewardName，默认"金币"
}
```

iOS（来自 `BUDExpressRewardedVideoViewController`）：
```dart
class IOSRewardedVideoConfig {
  final String slotId;
  final String rewardName;         // model.rewardName = "金币"
  final int rewardAmount;          // model.rewardAmount = 300
  // final String userId;          // model.userId（可选，demo中注释掉了，不复刻）
}
```

##### `AndroidFullscreenVideoConfig` / `IOSFullscreenVideoConfig`

Android（来自 `FullScreenVideoActivity`）：
```dart
class AndroidFullscreenVideoConfig {
  final String slotId;             // setCodeId
  final int adLoadType;            // setAdLoadType: 1=LOAD, 2=PRELOAD
}
```

iOS（来自 `BUDExpressFullScreenVideoViewController`）：
```dart
class IOSFullscreenVideoConfig {
  final String slotId;
  final bool isInterstitialAd;     // 是否作为新插屏展示（切换 interstitial/fullscreen slot）
}
```

##### `AndroidBannerConfig` / `IOSBannerConfig`（模板 Banner）

Android（来自 `BannerExpressActivity`）：
```dart
class AndroidBannerConfig {
  final String slotId;             // setCodeId
  final int adCount;               // setAdCount，固定1
  final double expressViewWidth;   // setExpressViewAcceptedSize width (dp)
  final double expressViewHeight;  // setExpressViewAcceptedSize height (dp)
}
```

iOS（来自 `BUDExpressBannerViewController`）：
```dart
class IOSBannerConfig {
  final String slotId;
  final double adWidth;            // adSize.width (pt)
  final double adHeight;           // adSize.height (pt)
  final int interval;              // 轮播间隔秒数，0=不轮播，demo中用30
}
```

iOS Banner 支持的尺寸（来自 `sizeDcit`）：

| SlotId | 尺寸(pt) |
|--------|---------|
| `900546269` (60×90) | 300×45 |
| `900546833` (640×100) | 320×50 |
| `900546198` (600×150) | 300×75 |
| `945509774` (690×388) | 345×194 |
| `900546387` (600×260) | 300×130 |
| `945509789` (600×300) | 300×150 |
| `945509785` (600×400) | 300×200 |
| `945509778` (600×500) | 300×250 |

##### `AndroidNativeBannerConfig` / `IOSNativeBannerConfig`（原生 Banner）

Android（来自 `NativeBannerActivity`）：
```dart
class AndroidNativeBannerConfig {
  final String slotId;             // setCodeId
  final int imageWidth;            // setImageAcceptedSize(600, 257)
  final int imageHeight;           // setImageAcceptedSize(600, 257)
  final bool supportRenderControl; // .supportRenderControl()
  final double expressViewWidth;   // setExpressViewAcceptedSize(350, 300) dp
  final double expressViewHeight;
  final int adCount;               // setAdCount(1)
}
```

iOS（来自 `BUDNativeBannerViewController`）：使用 `BUNativeAd`（自渲染），iOS 侧原生 Banner 为纯自渲染，Flutter PlatformView 展示，不抽取独立配置参数，直接使用 slotId + 宽高。

##### `AndroidFeedConfig` / `IOSFeedConfig`（模板信息流）

Android（来自 `NativeExpressActivity` / `NativeExpressListActivity`）：
```dart
class AndroidFeedConfig {
  final String slotId;             // setCodeId
  final int adCount;               // setAdCount(1~3)
  final double expressViewWidth;   // setExpressViewAcceptedSize width (dp)
  final double expressViewHeight;  // setExpressViewAcceptedSize height (dp)，0=自适应高
}
```

Android FeedIcon（来自 `NativeExpressIconActivity`）：
```dart
class AndroidFeedIconConfig {
  final String slotId;
  final int adCount;               // setAdCount(1)
  // .supportIconStyle()           // 必须调用
  final double expressViewWidth;   // setExpressViewAcceptedSize(160, 0)
}
```

iOS（来自 `BUDExpressFeedViewController`）：
```dart
class IOSFeedConfig {
  final String slotId;             // slot1.ID
  // BUAdSlotAdTypeFeed            // slot1.AdType（固定）
  final bool supportRenderControl; // slot1.supportRenderControl = YES
  // BUProposalSize_Feed228_150    // slot1.imgSize（固定）
  // BUAdSlotPositionFeed          // slot1.position（固定）
  final double adWidth;            // adSize.width (pt)
  final double adHeight;           // adSize.height (pt)，0=自适应
  final int adCount;               // loadAdDataWithCount
}
```

##### `AndroidDrawConfig` / `IOSDrawConfig`（Draw 竖版视频）

Android（来自 `DrawNativeExpressVideoActivity`）：
```dart
class AndroidDrawConfig {
  final String slotId;             // setCodeId("901121041")
  final double expressViewWidth;   // setExpressViewAcceptedSize width (dp) = 屏幕宽
  final double expressViewHeight;  // setExpressViewAcceptedSize height (dp) = 屏幕高
  final int adCount;               // setAdCount(2)
  // loadExpressDrawFeedAd         // 使用专用接口
}
```

iOS（来自 `BUDExpressDrawViewController`）：
```dart
class IOSDrawConfig {
  final String slotId;
  // BUAdSlotAdTypeDrawVideo       // slot1.AdType（固定）
  // BUProposalSize_DrawFullScreen // slot1.imgSize（固定）
  final double adWidth;            // adSize = view.bounds.size.width
  final double adHeight;           // adSize = view.bounds.size.height
  final int adCount;               // loadAdDataWithCount(3)
}
```

##### `AndroidStreamConfig` / `IOSStreamConfig`（Stream 自定义播放）

Android（来自 `StreamCustomPlayerActivity`）：
```dart
class AndroidStreamConfig {
  final String slotId;             // setCodeId("945593053")
  final int imageWidth;            // setImageAcceptedSize(640, 320)
  final int imageHeight;
  final int adCount;               // setAdCount(1)
  // loadStream                    // 使用专用接口
}
```

iOS（来自 `BUDCustomVideoPlayerViewController`）：
```dart
class IOSStreamConfig {
  final String slotId;             // slot.ID
  // BUAdSlotAdTypeFeed            // slot.AdType（固定）
  // BUAdSlotPositionTop           // slot.position（固定）
  // BUProposalSize_Feed690_388    // slot.imgSize（固定）
  final int adCount;               // loadAdDataWithCount(1)
}
```

---

#### 2.2 数据模型（`model.dart`）

```dart
// Draw 广告
class PangleDrawAd {
  final int count;
  final List<String> data;         // draw id 列表，同 feed 模式
}

// Stream 广告素材
class PangleStreamAd {
  final int count;
  final List<StreamAdItem> data;
}

class StreamAdItem {
  final String id;
  final int imageMode;             // TTAdConstant.IMAGE_MODE_*
  final String? videoUrl;          // 仅视频类型有值
  final double videoDuration;      // 视频时长（秒）
  final String? imageUrl;          // 图片类型主图
  final String? title;
  final String? description;
}
```

---

#### 2.3 Plugin 方法（`pangle_plugin.dart`）

```dart
// Feed 图标样式（需要单独方法，因为 AdSlot 参数不同）
Future<PangleAd> loadFeedIconAd({IOSFeedConfig? iOS, AndroidFeedIconConfig? android});

// Draw 广告
Future<PangleDrawAd> loadDrawAd({IOSDrawConfig? iOS, AndroidDrawConfig? android});
Future<int?> removeDrawAd(List<String> ids);

// Stream 广告
Future<PangleStreamAd> loadStreamAd({IOSStreamConfig? iOS, AndroidStreamConfig? android});
```

---

#### 2.4 新增 Widget

| Widget | 路径 | 说明 |
|--------|------|------|
| `DrawView` | `lib/src/view/drawview.dart` | 全屏竖版广告，同 FeedView 模式 |

---

### Phase 3：Android Plugin 实现

路径：`android/src/main/kotlin/io/github/nullptrx/pangleflutter/`

#### 3.1 Draw 广告

参考 `template/demo/DrawNativeExpressVideoActivity.java`：
- 在 `PangleAdManager.kt` 新增 `loadDrawAd()` 方法
- 使用 `TTAdNative.loadNativeExpressAd()` (with `AdSlot.setDrawCount()` 或竖版参数)
- 返回 draw id 列表，同 feed 的缓存方式

#### 3.2 Stream 广告

参考 `template/demo/StreamCustomPlayerActivity.java`：
- 在 `PangleAdManager.kt` 新增 `loadStreamAd()` 方法
- 使用 `TTAdNative.loadStream()`
- 返回视频 URL、图片 URL、素材数据

#### 3.3 NativeBanner（若需要）

参考 `template/demo/NativeBannerActivity.java`：
- 使用 `TTAdNative.loadNativeAd()` 加载原生 Banner
- 通过 PlatformView 渲染（复用现有 `FlutterBannerView.kt` 改造）

#### 3.4 开屏 isHalfSize 支持

在 `FLTSplashAd.kt` 中增加 `isHalfSize` 参数处理（`CSJSplashAd.SplashAdLoadCallback` 分支）。

---

### Phase 4：iOS Plugin 实现

路径：`ios/Classes/`

参考：`template/union_platform_iOS_7.6.0.3/DomesticDemo/BUDemo/`

#### 4.1 Draw 广告

参考 `BUDExpressDrawViewController.m`：
- 在 `PangleAdManager.swift` 新增 `loadDrawAd()`
- 使用 `BUNativeExpressAdManager` 加载竖版广告
- 返回 draw id 列表，同 feed

#### 4.2 Stream 广告

参考 `BUDCustomVideoPlayerViewController.m`：
- 在 `PangleAdManager.swift` 新增 `loadStreamAd()`
- 使用 `BUNativeAdsManager` 加载 stream
- 返回视频 URL 和素材

#### 4.3 原生 Banner（可选）

参考 `BUDNativeBannerViewController.m`：
- 使用 `BUNativeAd` 加载原生素材
- 通过 `FLTBannerView.swift` 的扩展渲染

#### 4.4 开屏半屏/互动开屏

参考 `BUDSplashViewController.m`：
- 在 `FLTSplashView.swift` 中支持 `isHalfSize` 参数

---

## 文件变更清单

### 新增 Flutter example 文件

```
example/lib/page/constant.dart                     # 更新（补充全部 ID）
example/lib/page/home_page.dart                    # 重写（8入口）
example/lib/page/splash/splash_list_page.dart      # 新增
example/lib/page/splash/splash_view_page.dart      # 新增（SplashView Widget 页）
example/lib/page/reward/reward_list_page.dart      # 新增
example/lib/page/reward/reward_page.dart           # 重写
example/lib/page/fullscreen/fullscreen_list_page.dart # 新增
example/lib/page/fullscreen/fullscreen_page.dart   # 重写
example/lib/page/banner/banner_list_page.dart      # 新增
example/lib/page/banner/banner_page.dart           # 重写
example/lib/page/feed/feed_list_page.dart          # 新增
example/lib/page/feed/feed_page.dart               # 重写
example/lib/page/feed/feed_icon_page.dart          # 新增
example/lib/page/draw/draw_list_page.dart          # 新增
example/lib/page/draw/draw_page.dart               # 新增
example/lib/page/stream/stream_page.dart           # 新增
example/lib/page/waterfall/waterfall_page.dart     # 新增
```

### 新增/修改 Flutter plugin Dart 层

```
lib/src/config_android.dart        # 新增 Draw/Stream/NativeBanner 配置类
lib/src/config_ios.dart            # 新增 Draw/Stream/NativeBanner 配置类
lib/src/model.dart                 # 新增 PangleDrawAd / PangleStreamAd
lib/src/pangle_plugin.dart         # 新增 loadDrawAd / removeDrawAd / loadStreamAd
lib/src/view/drawview.dart         # 新增 DrawView Widget
lib/src/view/draw/               # 新增（同 feed/banner 目录结构）
lib/pangle_flutter.dart            # 更新 export
```

### 修改 Android Plugin

```
android/src/main/kotlin/.../PangleAdManager.kt     # 新增方法
android/src/main/kotlin/.../delegate/FLTDrawAd.kt  # 新增
android/src/main/kotlin/.../delegate/FLTStreamAd.kt # 新增
android/src/main/kotlin/.../view/FlutterDrawView.kt # 新增（若需PlatformView）
android/src/main/kotlin/.../view/DrawViewFactory.kt # 新增
android/src/main/kotlin/.../PangleFlutterPlugin.kt  # 注册新工厂
```

### 修改 iOS Plugin

```
ios/Classes/PangleAdManager.swift           # 新增方法
ios/Classes/FLTDrawView.swift               # 新增
ios/Classes/DrawViewFactory.swift           # 新增
ios/Classes/SwiftPangleFlutterPlugin.swift  # 注册新工厂
```

---

## 实现顺序（详细步骤）

1. **更新 `constant.dart`** — 补充所有广告位 ID
2. **重写 `home_page.dart`** — 8 个入口，含 SDK 版本显示
3. **开屏广告页**（SplashListPage → SplashViewPage）— 直接用现有 `pangle.loadSplashAd()`
4. **激励视频页**（RewardListPage + RewardPage）— 用现有 `loadRewardedVideoAd()`，加横/竖屏切换
5. **全屏视频/新插屏页**（FullscreenListPage + FullscreenPage）— 用现有 `loadFullscreenVideoAd()`
6. **Banner 页**（BannerListPage）— 原生 Banner 需新 Plugin 接口；模板 Banner 已有
7. **信息流页**（FeedListPage）— 现有接口扩展，增加图标/列表变体
8. **Draw 页**（DrawListPage + DrawPage）— 需新 Plugin 接口 + DrawView Widget
9. **Stream 页**（StreamPage）— 需新 Plugin 接口
10. **瀑布流页**（WaterfallPage）— 复用 FeedView + GridView
11. **Flutter Plugin Dart 层** — 新增配置类、模型、plugin 方法
12. **Android Plugin 实现** — Draw/Stream/NativeBanner/isHalfSize
13. **iOS Plugin 实现** — 与 Android 对应功能

---

## 不实现内容（原因说明）

| 功能 | 原因 |
|------|------|
| 原生信息流（自渲染 Feed）| Flutter 中自渲染需完整实现广告 View，且原生 Demo 已有模板版代替，价值低 |
| 测试工具页（AllTestToolActivity）| 开发调试用途，不需要 |
| 竞价 Bidding 开屏（BUDBiddingSplashViewController）| 进阶功能，与基础 demo 无关 |
| 聚合广告（Gromore/Mediation）| 独立 SDK，本插件不支持 |

---

## 注意事项

1. Android 和 iOS 广告位 ID **不同**，`constant.dart` 中需分别定义，plugin 按 `Platform.isIOS` 选择
2. 开屏广告（`loadSplashAd`）在 Android 是全局 Activity，Flutter 侧只能通过 `MethodChannel` 触发原生显示，**不能用 Widget 嵌入**
3. Draw 广告（竖版全屏视频）在 Android 通过 `PlatformView` 实现，需要全屏的 Flutter 页面来承载
4. Stream 广告返回原始视频 URL，需要 Flutter 侧的视频播放器（如 `video_player` 包）播放，或者直接用原生 PlatformView 展示
5. `FeedView`/`DrawView`/`BannerView` 必须在限定尺寸的容器中（`Container`/`SizedBox`/`AspectRatio`）
6. iOS `loadSplashAd` 目前通过 `CSJSplashAd`（全新 API），`isHalfSize` 参数需检查 Pangle iOS SDK v5.x 是否支持
