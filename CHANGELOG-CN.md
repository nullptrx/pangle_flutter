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

```dart
FeedView(
  id: item.feedId,
  /// disable touch
  isUserInteractionEnabled: false,
)
```

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



