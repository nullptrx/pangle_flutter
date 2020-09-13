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




