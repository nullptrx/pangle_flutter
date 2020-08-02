# 穿山甲 Flutter SDK

[![pub package](https://img.shields.io/pub/v/pangle_flutter.svg)](https://pub.dartlang.org/packages/pangle_flutter) [![Licence](https://img.shields.io/github/license/nullptrX/pangle_flutter)](https://github.com/nullptrX/pangle_flutter/blob/master/LICENSE)

## 简介

pangle_flutter是一款集成了穿山甲`Android`和`iOS`SDK的Flutter插件。其中部分代码由官方demo修改而来。

- [Android Demo](https://github.com/bytedance/pangle-sdk-demo)
- [iOS Demo](https://github.com/bytedance/Bytedance-UnionAD)

## 官方文档（需要登陆）
- [穿山甲 Android SDK（Only support China traffic）](https://ad.oceanengine.com/union/media/union/download/detail?id=4&osType=android)

- [穿山甲 iOS SDK](https://ad.oceanengine.com/union/media/union/download/detail?id=16&osType=ios)

## 集成步骤

### 1. 添加yaml依赖
```yaml
dependencies:
  # 添加依赖
  pangle_flutter: latest
```
### 2. Android和iOS额外配置

#### [README](SETUP.md)




## 使用步骤

### 1. 初始化

```dart
import 'package:pangle_flutter/pangle_flutter.dart';
/// 如果在runApp方法调用之前初始化，加入下面这句代码
WidgetsFlutterBinding.ensureInitialized();
/// 初始化，未列出所有参数，后面会有详细说明
/// [kAppId] 申请穿山甲广告位后得到的appID
await pangle.init(
  iOS: IOSConfig(appId: kAppId),
  android: AndroidConfig(appId: kAppId),
);
```



### 2. 开屏广告

```dart
/// [kSplashId] 开屏广告ID, 对应Android的CodeId，对应iOS的slotID
await pangle.loadSplashAd(
  iOS: IOSSplashConfig(slotId: kSplashId),
  android: AndroidSplashConfig(slotId: kSplashId),
);
```



### 3. 激励视频广告

```dart
/// [kRewardedVideoId] 激励视频广告ID, 对应Android的CodeId，对应iOS的slotID
pangle.loadRewardVideoAd(
   iOS: IOSRewardedVideoConfig(slotId: kRewardedVideoId),
   android: AndroidRewardedVideoConfig(slotId: kRewardedVideoId),
 );
```



### 4. Banner广告

```dart
/// Banner通过PlatformView实现，使用方法同Widget
/// [kBannerId] Banner广告ID, 对应Android的CodeId，对应iOS的slotID
BannerView(
  iOS: IOSBannerAdConfig(slotId: kBannerId),
  android: AndroidBannerAdConfig(slotId: kBannerId),
),
```



### 5. 信息流广告

- 获取信息流数据

```dart
/// 信息流实现逻辑
/// 首先进行网络请求，得到信息流数据
/// PangleFeedAd相应字段
/// 响应码，0成功，-1失败
/// final int code;
/// 错误时，调试信息
/// final String message;
/// 获得信息流数量，一般同上面传入的count，最终结果以此count为主
/// final int count;
/// 用于获取信息流广告的键id
/// final List<String> data;
 PangleFeedAd feedAd = await pangle.loadFeedAd(
   iOS: IOSFeedAdConfig(slotId: kFeedId, count: 2),
   android: AndroidFeedAdConfig(slotId: kFeedId, count: 2),
 );

```

- 加载数据

```dart
/// 使用方法
/// 你的数据模型
class Item {
  /// 添加字段
  final String feedId;
}
final items = <Item>[];
final feedAdDatas = feedAd.data;
final item = Item(feedId: feedAdDatas[0]);
item.insert(Random().nextInt(item.length), item);
/// Widget使用
FeedView(
  id: item.feedId,
  onRemove: () {
    setState(() {
      items.removeAt(index);
    });
  },
)
```



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
/// [hideSkipButton] optional. Whether hide skip button, default NO. If you hide the skip button, you need to customize the countdown.
IOSSplashConfig({
  @required this.slotId,
  this.tolerateTimeout,
  this.hideSkipButton,
});

/// The splash ad config for Android
///
/// [slotId] The unique identifier of splash ad.
/// [tolerateTimeout] optional. Maximum allowable load timeout, default 3s, unit s.
/// [hideSkipButton] optional. Whether hide skip button, default NO. If you hide the skip button, you need to customize the countdown.
/// [isExpress] optional. experimental. 个性化模板广告
AndroidSplashConfig({
  @required this.slotId,
  this.tolerateTimeout,
  this.hideSkipButton,
  this.isExpress,
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
IOSRewardedVideoConfig({
  @required this.slotId,
  this.userId,
  this.rewardName,
  this.rewardAmount,
  this.extra,
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
AndroidRewardedVideoConfig({
  @required this.slotId,
  this.userId,
  this.rewardName,
  this.rewardAmount,
  this.extra,
});
```



### Banner配置

```dart
/// The feed ad config for iOS
///
/// [slotId] required. The unique identifier of a feed ad.
/// [imgSize] required. Image size.
IOSBannerAdConfig({
  @required this.slotId,
  this.imgSize = PangleImgSize.feed690_388,
  this.count,
});

/// The feed ad config for Android
///
/// [slotId] required. The unique identifier of a feed ad.
/// [imgSize] required. Image size.
/// [isSupportDeepLink] optional. Whether to support deeplink.
AndroidBannerAdConfig({
  @required this.slotId,
  this.imgSize = PangleImgSize.feed690_388,
  this.isSupportDeepLink,
});
```



### 信息流配置

```dart
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

/// The feed ad config for iOS
///
/// [slotId] required. The unique identifier of a feed ad.
/// [imgSize] required. Image size.
/// [tag] optional. experimental. Mark it.
/// [count] It is recommended to request no more than 3 ads. The maximum is 10. default 3
/// [isSupportDeepLink] optional. Whether to support deeplink.
AndroidFeedAdConfig({
  @required this.slotId,
  this.imgSize = PangleImgSize.feed690_388,
  this.tag,
  this.count,
  this.isSupportDeepLink,
});
```



## 使用说明

1. 开屏广告放在runApp之前（个人感觉理论上也应该这儿），之前使用`activity.addContentView()`方式实现存在两种非正常情况

   - 内容页先出现的问题
   - 内容页没有渲染，开屏广告结束后，界面黑屏（FlutterView未成功渲染）

   后使用DialogFragment的方式实现后，暂未出现以上问题。

2. 信息流广告之前在PlatformView创建成功后再load的方式，改为创建时load。然后使用获取的FeedAd对象的hashCode作为key全局缓存，通过Flutter中FeedView传入的id，寻找对应广告对象。

   从而解决了移除item（`setState((){});`）时，出现广告对象消失的问题。

3. iOS信息流广告的点击事件需要传入`rootViewController`，使用的是`(UIApplication.shared.delegate?.window??.rootViewController)!`，暂未发现问题。

4. 屏幕旋转更新FeedView宽高暂未完成



## 贡献

- 有任何更好的实现方式或增加额外的功能，欢迎提交PR。
- 有任何使用上的问题，请提交issue。

