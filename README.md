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

### 6. 插屏广告

```dart
 final result = await pangle.loadInterstitialAd(
   iOS: IOSInterstitialAdConfig(
     slotId: kInterstitialId,
     isExpress: true,

     /// 该宽高为你申请的广告位宽高，请根据实际情况赋值
     imgSize: PangleImgSize.interstitial600_400,
   ),
   android: AndroidInterstitialAdConfig(
     slotId: kInterstitialId,
     isExpress: true,
   ),
 );
print(jsonEncode(result));
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
/// [isSupportDeepLink] optional. Whether to support deeplink. default true.
AndroidSplashConfig({
  @required this.slotId,
  this.tolerateTimeout,
  this.hideSkipButton,
  this.isExpress,
  this.isSupportDeepLink,
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
/// [isVertical] optional. Whether video is vertical orientation. Vertical, if true. Otherwise, horizontal.
/// [isSupportDeepLink] optional. Whether to support deeplink. default true.
AndroidRewardedVideoConfig({
  @required this.slotId,
  this.userId,
  this.rewardName,
  this.rewardAmount,
  this.extra,
  this.isVertical,
  this.isSupportDeepLink,
});
```



### Banner配置

```dart
/// The feed ad config for iOS
///
/// [slotId] required. The unique identifier of a feed ad.
/// [imgSize] required. Image size.
/// [isExpress] optional. 个性化模板广告.
IOSBannerAdConfig({
  @required this.slotId,
  this.imgSize = PangleImgSize.banner600_150,
  this.count,
  this.isExpress,
});

/// The feed ad config for Android
///
/// [slotId] required. The unique identifier of a feed ad.
/// [imgSize] required. Image size.
/// [isSupportDeepLink] optional. Whether to support deeplink.
/// [isExpress] optional. 个性化模板广告.
AndroidBannerAdConfig({
  @required this.slotId,
  this.imgSize = PangleImgSize.banner600_150,
  this.isSupportDeepLink,
  this.isExpress,
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
/// [isExpress] optional. 个性化模板广告.
IOSFeedAdConfig({
  @required this.slotId,
  this.imgSize = PangleImgSize.feed690_388,
  this.tag,
  this.count,
  this.isSupportDeepLink,
  this.isExpress,
});

/// The feed ad config for iOS
///
/// [slotId] required. The unique identifier of a feed ad.
/// [imgSize] required. Image size.
/// [tag] optional. experimental. Mark it.
/// [count] It is recommended to request no more than 3 ads. The maximum is 10. default 3
/// [isSupportDeepLink] optional. Whether to support deeplink.
/// [isExpress] optional. 个性化模板广告.
AndroidFeedAdConfig({
  @required this.slotId,
  this.imgSize = PangleImgSize.feed690_388,
  this.tag,
  this.count,
  this.isSupportDeepLink,
  this.isExpress,
});
```

### 插屏广告

```dart
/// The interstitial ad config for iOS
///
/// [slotId] required. The unique identifier of a interstitial ad.
/// [imgSize] required. Image size.
/// [isExpress] optional. 个性化模板广告.
IOSInterstitialAdConfig({
  @required this.slotId,
  this.imgSize = PangleImgSize.interstitial600_400,
  this.isExpress,
})


/// The interstitial ad config for Android
///
/// [slotId] required. The unique identifier of a interstitial ad.
/// [imgSize] required. Image size.
/// [isExpress] optional. experimental. 个性化模板广告
/// [isSupportDeepLink] optional. Whether to support deeplink. default true.
AndroidInterstitialAdConfig({
  @required this.slotId,
  this.imgSize = PangleImgSize.interstitial600_400,
  this.isSupportDeepLink,
  this.isExpress,
})
```



## 使用说明

1. 开屏广告放在runApp之前调用体验最佳
2. 信息流广告之前在PlatformView创建成功后再load的方式，改为创建时load。然后使用获取的FeedAd对象的hashCode作为key全局缓存，通过Flutter中FeedView传入的id，寻找对应广告对象。

   从而解决了移除item（`setState((){});`）时，出现广告对象消失的问题。

3. iOS信息流广告的点击事件需要传入`rootViewController`，使用的是`(UIApplication.shared.delegate?.window??.rootViewController)!`，暂未发现问题。

4. 如果Android应用没有授予`READ_PHONE_STATE`权限，有可能出现这样的错误

```
U SHALL NOT PASS!
E  java.lang.SecurityException: getDeviceId: The user 10285 does not meet the requirements to access device identifiers.
E      at android.os.Parcel.createException(Parcel.java:2071)
E      at android.os.Parcel.readException(Parcel.java:2039)
E      at android.os.Parcel.readException(Parcel.java:1987)
E      at com.android.internal.telephony.ITelephony$Stub$Proxy.getDeviceId(ITelephony.java:10590)
E      at android.telephony.TelephonyManager.getDeviceId(TelephonyManager.java:1619)
E      at com.bytedance.embedapplog.bm.a(SourceFile:12)
E      at com.bytedance.embedapplog.an.a(SourceFile:38)
E      at com.bytedance.embedapplog.aa.e(SourceFile:183)
E      at com.bytedance.embedapplog.k.handleMessage(SourceFile:128)
E      at android.os.Handler.dispatchMessage(Handler.java:103)
E      at android.os.Looper.loop(Looper.java:214)
E      at android.os.HandlerThread.run(HandlerThread.java:67)
```

5. 插屏广告不显示问题

```java
// open_ad_sdk:
// com.bytedance.sdk.openadsdk.utils.a:28处有生命周期的监控, 
// FlutterActivity跳转界面时一定情况下不会回调onStart(),onStop()
// 如使用ttAdManager.requestPermissionIfNecessary(context)时，就不会调用。
// 上述情况，导致onActivityStarted少走了一次，因此下面的show方法走不通。
public void onActivityStarted(Activity var1) {
  if (this.a.incrementAndGet() > 0) {
    this.b.set(false);
  }

  this.b();
}
...

public void onActivityStopped(Activity var1) {
  if (this.a.decrementAndGet() == 0) {
    this.b.set(true);
  }

}

// com.bytedance.sdk.openadsdk.core.c.b:306处有生命周期的判断，无法执行show()
if (!this.k.isShowing() && !com.bytedance.sdk.openadsdk.core.i.c().a()) {
  this.k.show();
}

```

6. `BannerView`、`FeedView`通过PlatformView实现。在安卓上，PlatformView最低支持API 20。





## 贡献

- 有任何更好的实现方式或增加额外的功能，欢迎提交PR。
- 有任何使用上的问题，欢迎提交issue。

