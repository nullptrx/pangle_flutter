[English](CHANGELOG.md) | 中文

---

## 3.0.1

### 新功能

- **聚合（Mediation）支持**：`IOSConfig` 和 `AndroidConfig` 均新增 `useMediation` 参数。设为 `true` 可启用穿山甲 GroMore 聚合功能。

```dart
await pangle.init(
  iOS: const IOSConfig(appId: kIOSAppId, useMediation: true),
  android: const AndroidConfig(appId: kAndroidAppId, useMediation: true),
);
```

### SDK 依赖更新

- **iOS**：从 `Ads-CN ~> 7.0` 切换为 `Ads-CN-Beta/BUAdSDK ~> 7.0` + `Ads-CN-Beta/CSJMediation ~> 7.0`
- **Android**：从 `com.pangle.cn:ads-sdk-pro` 切换为 `com.pangle_beta.cn:mediation-sdk`

### Example 示例工程

- **测量测试工具**：iOS 和 Android 均接入 `BUAdTestMeasurementManager`，Debug 包点击 🐛 按钮可唤起穿山甲测试页面。
- **主题切换**：首页第一项新增 SDK 主题切换（日间 / 夜间）入口。
- **初始化页面**：SDK 初始化逻辑迁移至独立的 `SetupPage`，进入主菜单前完成初始化。

---

## 3.0.0

### 新功能

#### Draw 竖版全屏视频广告

类似 TikTok 的竖向滑动全屏视频广告。批量加载 ID 后，在全屏 `PageView` 中逐一展示。

```dart
// 1. 加载
final PangleDrawAd drawAd = await pangle.loadDrawAd(
  iOS: IOSDrawConfig(slotId: kDrawId, adCount: 3),
  android: AndroidDrawConfig(slotId: kDrawId, adCount: 2),
);

// 2. 展示 — 嵌入全屏 PageView
DrawView(
  id: drawAd.data.first,
  onClick: () {},
  onShow: () {},
  onRenderFail: (code, msg) {},
)

// 3. 释放
await pangle.removeDrawAd(drawAd.data);
```

#### Stream 自定义播放广告

返回视频 URL 及元数据，供自定义播放器使用，无需 SDK 渲染视图。

```dart
final PangleStreamAd streamAd = await pangle.loadStreamAd(
  iOS: IOSStreamConfig(slotId: kStreamId),
  android: AndroidStreamConfig(slotId: kStreamId),
);
for (final StreamAdItem item in streamAd.data) {
  // item.videoUrl, item.title, item.imageUrl, item.videoDuration 等
}
```

#### EcMall 电商原生广告

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
    onError: (code, msg) {},
  ),
)
```

#### 信息流图标广告

适用于紧凑型列表或网格布局的图标尺寸广告，使用标准 `FeedView` 渲染。

```dart
final PangleAd iconAd = await pangle.loadFeedIconAd(
  android: AndroidFeedIconConfig(slotId: kFeedIconId),
);
FeedView(id: iconAd.data.first)
```

#### 半全屏开屏广告（Android）

展示占屏幕约 4/5 高度的开屏广告，而非完整全屏。仅 Android 支持。

```dart
await pangle.loadSplashAd(
  android: AndroidSplashConfig(slotId: kSplashId, isHalfSize: true),
  iOS: IOSSplashConfig(slotId: kSplashId),
);
```

---

- **[Dart]** `BannerView` 和 `FeedView` 现在根据 `expressSize` 在内部自动应用 `AspectRatio`（`height > 0` 时生效），无需在外层手动套 `AspectRatio` 或指定匹配高度。`FeedView` 新增可选参数 `expressSize`，传入与 `loadFeedAd` 相同的值即可。

### Bug 修复
- **[Android]** SDK 初始化改用 `applicationContext`，消除进程重启后的上下文泄漏问题。开屏广告不再依赖 `FragmentActivity`，普通 `Activity` 即可。
- **[iOS]** 修复严重 Bug：`PangleEventStreamHandler` 中插屏广告的事件 sink 错误指向了全屏广告 sink，导致插屏回调静默丢失
- **[iOS]** 修复 `FeedViewFactory` 中一个死代码静态方法 `initWithMessenger`，该方法错误返回了 `BannerViewFactory` 实例
- **[iOS]** 修复 `FLTView` 中获取 keyWindow 时存在的双重强制解包（`!!`）

### 安全性与稳定性
- **[iOS]** 将 `PangleAdManager`、`FLTRewardedVideoExpressAdTask`、`FLTFullscreenVideoExpressAdTask` 中所有异步闭包的 `[unowned self]` 替换为 `[weak self]` + `guard let self`，防止对象释放后可能出现的崩溃
- **[iOS]** 将 `FLTNativeExpressAdTask`、`FLTBannerView` 等处的强制类型转换（`as!`、`!`）替换为安全的 `guard let` 可选绑定

### API 现代化
- **[iOS]** 弃用 `UIApplication.shared.windows` / `keyWindow`，改用基于 `connectedScenes` 的方式，兼容多 window 和 Scene 生命周期管理
- **[iOS]** podspec 中 `swift_version` 从 `5.0` 升级至 `5.9`
- **[Android]** 弃用的枚举 `.values()[index]` 改为 `.entries.getOrNull(index)` 并附带安全默认值（`PangleLoadingType`、`PangleOrientation`、`PangleTitleBarTheme`）
- **[Android]** 弃用的 `systemUiVisibility` 在 API 30+ 改用 `WindowInsetsController`；API 24–29 保留兼容路径
- **[Android]** `PangleFlutterPlugin` 中的包级常量添加 `const` 修饰符

### 性能优化
- **[Android]** `FlutterBannerView`、`FlutterFeedView`、`FlutterSplashView`、`FlutterEcMallView` 中将 `Handler(Looper.getMainLooper())` 改为类字段缓存，避免每次调用重复创建对象
- **[Dart]** 顶层屏幕尺寸变量（`kPangleScreenWidth`、`kPangleScreenHeight`）改为 `late final`，延迟到首次访问时才初始化

### 新功能

#### 加载/展示分离 — `RewardedAd` & `FullscreenAd`

激励视频和全屏视频广告现在各自拥有独立的包装对象，彻底将加载与展示分离。`load()` 是静态工厂方法，成功时返回广告实例，失败时抛出 `AdLoadException`，无需再手动判断 `result.code`。

```dart
try {
  final ad = await RewardedAd.load(
    slotId: 'your_slot_id',
    iOS: const IOSRewardedVideoConfig(slotId: 'xxx'),
    android: AndroidRewardedVideoConfig(slotId: 'xxx'),
  );
  // 能走到这里就说明加载成功
  final result = await ad.show(
    onEvent: (event) {
      if (event case AdRewardEvent(:final verified) when verified) {
        grantReward();
      }
    },
  );
} on AdLoadException catch (e) {
  debugPrint('加载失败: $e');
}
```

`FullscreenAd` 模式相同：`FullscreenAd.load()` / `ad.show()`。

#### 预加载池 — `RewardedAdPool` & `FullscreenAdPool`

单例池管理器负责预加载、缓存查询和展示后自动补充。

```dart
// 应用启动时配置一次
await RewardedAdPool.instance.configure(
  slotId: 'your_slot_id',
  poolSize: 2,           // 同时维持 2 个缓存
  autoRefill: true,      // 展示后自动补充
  iOS: const IOSRewardedVideoConfig(slotId: 'xxx'),
  android: AndroidRewardedVideoConfig(slotId: 'xxx'),
);

if (await RewardedAdPool.instance.isReady('your_slot_id')) {
  await RewardedAdPool.instance.show(
    slotId: 'your_slot_id',
    onEvent: (event) { ... },
  );
}
```

#### 类型安全事件 — `PangleAdEvent` sealed class

所有 native 事件字符串现在映射为 sealed class，支持编译期穷举检查：

```dart
switch (event) {
  case AdRewardEvent(:final verified): ...
  case AdClosedEvent():               ...
  case AdErrorEvent():                ...
  default:                            ...
}
```

全部子类型：`AdLoadedEvent`、`AdCachedEvent`、`AdShownEvent`、`AdSkippedEvent`、`AdClickedEvent`、`AdCompletedEvent`、`AdClosedEvent`、`AdErrorEvent`、`AdRenderFailedEvent`、`AdRenderSuccessEvent`、`AdRewardEvent`、`AdUnknownEvent`。

#### Native：新增 show / has 方法

- **[Android/iOS]** 新增 `showRewardedVideoAd(slotId)` 和 `showFullscreenVideoAd(slotId)` method channel 调用，可展示缓存广告而不触发新的加载请求。
- **[Android/iOS]** 新增 `hasRewardedVideoAd(slotId)` 和 `hasFullscreenVideoAd(slotId)`，查询 native 缓存中是否存在未过期的广告。
- **[Android]** `PangleAdManager`：新增 `hasRewardedVideoAd()` 和 `hasFullscreenVideoAd()`，复用与 `showRewardedVideoAd()` 相同的过期检测逻辑。
- **[iOS]** `PangleAdManager`：新增 `hasRewardedVideoAd(_:)` 和 `hasFullscreenVideoAd(_:)`，通过 `adQueue.sync` 保证线程安全。

#### SplashView
- **[iOS/Android/Dart]** 区分 `SplashView` 错误回调：`onRenderFail`（渲染失败）和 `onError`（加载失败），与 `BannerView` 现有模式保持一致
- **[SplashView]** `SplashView` widget 新增 `onRenderFail` 回调参数

### 废弃

- `pangle.loadRewardedVideoAd()` — 请改用 `RewardedAd.load()` / `RewardedAdPool`。
- `pangle.loadFullscreenVideoAd()` — 请改用 `FullscreenAd.load()` / `FullscreenAdPool`。
- `PangleLoadingType` — 已成为内部实现细节，业务代码不应再引用。

### 改进
- **[Dart]** `IOSRewardedVideoConfig`、`IOSFullscreenVideoConfig`、`AndroidRewardedVideoConfig`、`AndroidFullscreenVideoConfig` 新增 `copyWith()` 方法。
- **[iOS]** 简化 `FLTView.hitTest`：移除基于类名字符串的 `FlutterOverlayView` 检测逻辑（Flutter 3+ 切换到 TLHC 渲染模式后已是 dead code）。`touchableBounds` 现在直接限制原生广告 View 的可点击区域。
- **[iOS]** 清理 `UIUtil`：移除 `isOverlay`、`findTargetView`、`findTargetOverlayView`（Flutter 3+ TLHC 模式下的死代码）
- **[Android]** `SurfaceAndroidBannerView`、`SurfaceAndroidFeedView`、`SurfaceAndroidSplashView` 移除 `hybridComposition` 参数，统一使用 TLHC（`initSurfaceAndroidView`）；移除 Hybrid Composition 路径（`initExpensiveAndroidView`）；`AndroidViewMixin.createView` 同步简化。

### 代码清理
- **[Android]** 移除已弃用的 `NativeSplashDialog` 实现，开屏对话框统一使用基于 AndroidX 的 `SupportSplashDialog`
- **[Android]** 移除 API level < 24（低于 minSdk）的死代码分支
- **[Android]** 移除 `PangleAdManager` 中 `ttAdNative` 的冗余 `get() = field` getter

### Dart / Flutter 现代化
- **[Dart]** 修复 `feedview_method_channel.dart` 和 `bannerview_method_channel.dart` 中内部方法调用处理器的返回类型：`Future<dynamic>` → `Future<void>`
- **[Dart]** 为 `util.dart` 中三个公共 typedef 添加显式 `void` 返回类型（`PangleSplashCloseTypeCallback`、`PangleMessageCallback`、`PangleOptionCallback`）
- **[Dart]** **破坏性变更：** `PangleOrientation.veritical` 重命名为 `PangleOrientation.vertical`（拼写错误修正），请同步更新使用处。Kotlin 侧 `PangleOrientation.veritical` 同步改名；枚举序号不变。
- **[Dart]** 将 `splashview_method_channel.dart`、`model.dart`、`pangle_plugin.dart` 中不安全的 `List.values[index]` 枚举访问替换为 `.elementAtOrNull()` + 安全默认值
- **[Dart]** 移除 `BannerViewController`、`FeedViewController`、`SplashViewController` 中的死代码字段（`_bannerViewPlatformController`、`_feedViewPlatformController`、`_splashViewPlatformController`、`_platformCallbacksHandler`、`_widget`）及无实际作用的 `_updateWidget` 方法；移除三个 view 文件中多余的 `dart:async` 导入
- **[示例]** `feed_page.dart` 中 `MediaQuery.of(context).size.width` 更新为 `MediaQuery.sizeOf(context).width`

### 广告加载与缓存
- **[Android]** `FlutterFeedView` 在请求的广告不在缓存中时，现在会向 Dart 触发 `onRenderFail(code=-1)`，不再静默显示空白视图
- **[Android]** `FlutterFeedView.dispose()` 现在会调用 `removeExpressAd()` 以正确销毁底层 `TTNativeExpressAd`，防止 Flutter 组件移除后出现内存泄漏
- **[iOS]** `FLTFeedView.deinit` 现在会调用 `PangleAdManager.shared.removeExpressAd()` 以在 platform view 销毁时释放缓存中的 `BUNativeExpressAdView`
- **[iOS]** `FeedView.loadExpressAd()` 在缓存中找不到广告时，现在会向 Dart 触发 `onRenderFail(code=-1)`（与 Android 行为对齐）
- **[iOS]** 在 `PangleAdManager` 中为激励视频和全屏视频广告缓存新增 `CachedVideoAd` 包装结构体，支持 30 分钟有效期（TTL）。每次展示前自动清除过期条目，与 Android 端 SDK 提供的 `expirationTimestamp` 检查对齐
- **[iOS]** `removeExpressAd()` — 移除强制解包（`key!`），添加 `@discardableResult`

---

## 2.0.1

- 优化Hybrid Composition的使用

## 2.0.0

- 升级ads sdk到5.0+
- 移除海外sdk的适配方法
- 移除插屏广告实现（根据文档已由全屏广告接管，需将原调用方法改为`loadFullscreenVideoAd`）
- loadBannerAd已适配为使用NativeAd实现
- 修复并优化开屏广告实现

## 1.9.7

- 修复代码警告问题。

## 1.9.2
- 修复 [#87]， 方法过时。

## 1.9.1
- 优化文档 (点击穿透)

## 1.9.0
- 修复iOS点击穿透问题
- 移除updateTouchableBounds和updateRestrictedBounds
- 新增addTouchableBounds和clearTouchableBounds方法(额外点击区域)

## 1.8.0
- 适配穿山甲SDK 4.7+ (Android & iOS)
- [SplashView] 移除onSkip、onTimeOver,新增onClose
- [SplashView] 修复Android中expressSize无效问题

## 1.7.0

- 适配穿山甲SDK 4.6+ (Android & iOS)
- 适配flutter 3.0.0
- 新增getDeviceInfo方法

## 1.6.0

- 适配穿山甲SDK 4.3+ (Android & iOS)
- AndroidSplashConfig,IOSSplashConfig移除splashButtonType
- Android相关Config移除downloadType
- IOSConfig添加gdpr, idfa参数
- iOS添加openGDPRPrivacy方法

## 1.5.0+1

- 正式

## 1.5.0+1-beta

- 添加useHybridComposition参数 (AndroidSplashView, AndroidBannerView, AndroidFeedView)

## 1.5.0-beta

- 升级穿山甲SDK
    - Android: AndroidRewardedVideoConfig中删除 rewardName，rewardAmountc参数
    - iOS: IOSConfig中删除 isPaidApp参数

## 1.4.7

- 修复FLTSplashView中类型转换问题

## 1.4.6

- useTextureView属性默认为true(pangle.init(...))
- 优化gradle依赖库版本限制
- 新增插屏、全屏视频、激励视频事件回调

## 1.4.5

- 修复iOS中SplashView的onLoad不回调问题
- 修复iOS中初始化参数isPaidApp误写成coppa
- 优化因SDK升级导致iOS中SplashView无法自适应屏幕大小的问题，新增PangleExpressSize配置显示大小

## 1.4.4

- SplashView新增onLoad回调

## 1.4.3

- 降级kotlin依赖版本

## 1.4.2

- 修复不兼容v2 版本嵌入警告

## 1.4.1

- 修复IOSSplashConfig设置splashButtonType无效

## 1.4.0

- 升级android sdk版本到3.9.0.5,ios sdk版本到3.9+
- 请求广告添加新选项(开屏广告点击区域 & 安卓下载二次确认弹窗)

## 1.3.0

- 升级android sdk版本到3.9+,ios sdk版本到3.8+
- 移除open_ad_sdk模块, 使用maven仓库代替aar包
- 优化范例

## 1.2.0

- 适配广告SDK(Android 3.8.0.0, iOS 3.7.0.5)
- 修复 iOS 上 FeedView 的 onDislike 不回调

## 1.1.0

- 适配Android海外SDK功能

## 1.0.1

- 解决Android Module依赖方式打包失败的问题

## 1.0.0

- null-safety

## 0.10.1

* 移除对自渲染广告的支持（isExpress参数移除）
* 优化激励视频和全屏视频的加载
* 修复 #20
* 重构`BannerView`, `FeedView`, `SplashView`
* 增加`pangle.removeFeedAd()`接口（清除信息流广告缓存）

## 0.9.1

* 适配open_ad_sdk 3.5.0.0, iOS不受影响

## 0.8.2

* 修复属性`tolerateTimeout`类型转换错误
* 修复范例Podfile中没有引入插件`pangle_flutter`

## 0.8.1

* 适配穿山甲SDK 3.4+（iOS SDK部分类移除，iOS部分字段过时）
* PangleResult 新增属性 `verify`

## 0.7.1

* 升级`Bytedance-UnionAD`最小依赖版本为3.3

## 0.6.5

* 适配激励视频onRewardVerify/nativeExpressRewardedVideoAdServerRewardDidSucceed奖励回调

## 0.6.4

* 修复FeedView,BannerView处理 `dispose`的异常

## 0.6.3

* 优化静态分析

## 0.6.2

* 支持自定义开屏广告 [#10]
* 升级穿山甲SDK

## 0.6.1

* 修复Banner渲染超过5秒的问题
* 重命名`PangleFeedAd`为`PangleAd`
* `BannerView`新增`interval`属性

## 0.5.1

* 移除`loadAwait`
* 适配`open_ad_sdk 3.3.0.0`
* podspec 使用`'Bytedance-UnionAD', '~>3.2'` 

## 0.4.3

* iOS 增加 `isUserInteractionEnabled` 广告位点击冲突解决方案
* 开屏广告状态回调
* 修复开屏广告展示错误

## 0.4.2

* iOS 配置增加 `isUserInteractionEnabled` 属性
* 修复激励视频和全屏视频回调在安卓上崩溃

## 0.4.1

* 重大变化
* 将返回类型为`Map`的方法替换为 `PangleResult`
* 支持iOS 14进行请求跟踪授权

## 0.3.6

* 修复iOS的模版渲染广告宽高显示不正常

## 0.3.5

* 重构Android & iOS实现。
* 修复加载激励视频广告和全屏视频广告内存泄漏的问题。
* 优化请求各类广告的回调消息。

## 0.3.4

* 在flutter android sdk上, 支持 `registerWith` 方式加载本插件。
* 重命名 `loadRewardVideoAd` 为 `loadRewardedVideoAd`.

## 0.3.3

* 从Android和iOS移除第三方图像加载框架的依赖性。

## 0.3.2

* 降级 `Bytedance-UnionAD`到 `v3.2.0.1`

## 0.3.1

* 适配 `open_ad_sdk`到 `v3.2.5.1`
* 修复SDK打印日志的问题 (#7)

## 0.2.1

* 升级Bytedance-UnionAD到v3.2.5.1
* 升级open_ad_sdk到v3.2.5.0
* 全新expressSize请求广告（之前使用错误，导致广告错位或渲染不全）
* 修复iOS的BannerView、FeedView触摸事件无效的问题

## 0.1.11

* 闪屏广告 `loadAwait` 功能
* 插屏广告结束后再产生回调

## 0.1.10

* 支持设置横幅广告、信息流模板渲染广告自定义宽高

## 0.1.9

* 修复ConstraintLayout的Group控件高度不起作用的问题。

## 0.1.8

* 优化BannerView，使它的配置信息空时不再崩溃。
* 使用新的配置类名。

## 0.1.7

* 修复激励视频回调问题。
* 支持全屏视频广告加载。

## 0.1.6

* 修复Feed广告高度展示不准确问题。
* 支持激励视频预加载。

## 0.1.5

* 重构iOS加载广告逻辑。
* 支持开屏模版渲染(未测试)、激励视频模版渲染。

## 0.1.4

* 修复安卓信息流加载问题。

## 0.1.3

* 信息流广告支持模版渲染。
* 优化BannerView、FeedView刷新逻辑（使用GlobalObjectKey防止PlatformView被销毁）。

## 0.1.2

* 插屏广告、Banner广告支持模版渲染。
* 优化BannerView、FeedView移除逻辑。

## 0.1.1

* 新增插屏广告。
* Android原生请求权限不建议使用。

## 0.0.6

* 移除弱引用实现，防止FlutterResult回调失败。


## 0.0.5

* 增加FeedView，BannerView点击移除时的默认实现。


## 0.0.4

* Android布局使用ConstraintLayout减少布局嵌套。
* 优化FeedView，BannerView加载逻辑。


## 0.0.3

* 格式化项目。


## 0.0.2

* 修正Dart Analysis中的问题。


## 0.0.1

* 初步实现开屏、激励视频、Banner、信息流广告。



