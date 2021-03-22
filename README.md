# 穿山甲 Flutter SDK

[![pub package](https://img.shields.io/pub/v/pangle_flutter.svg)](https://pub.dartlang.org/packages/pangle_flutter) [![Licence](https://img.shields.io/github/license/nullptrX/pangle_flutter)](https://github.com/nullptrX/pangle_flutter/blob/master/LICENSE) [![flutter](https://img.shields.io/badge/flutter-2.0.1-green)](https://flutter.dev/docs/get-started/install) 



## 简介

`pangle_flutter`是一款集成了穿山甲 Android 和 iOS SDK的Flutter插件。部分代码由官方范例修改而来。

- [Android Demo](https://github.com/bytedance/pangle-sdk-demo)
- [iOS Demo](https://github.com/bytedance/Bytedance-UnionAD)



> 从 [0.10.1](https://pub.flutter-io.cn/packages/pangle_flutter/versions/0.10.1) 开始，不再支持旧版自渲染方式加载广告。所有可请求广告为[穿山甲官网](https://pangle.cn)目前可创建广告位。
>
> 因自渲染广告位，官方不推荐使用，且API不会经常变动，后续会单独提交一个自渲染版本出来。如果你仍需要该功能，可使用[0.9.1](https://pub.flutter-io.cn/packages/pangle_flutter/versions/0.9.1)或在其基础上修改。



## 版本迁移至0.10.1

> 1. 不再需要传入isExpress参数
> 2. BannerView, FeedView, SplashView均需要包一层限制大小的Widget, 可选Container, SizeBox, AspectRatio, Expanded等
> 3. BannerView, FeedView, SplashView的控制点击实现变动，可参考example进行更改。
> 4. 从v0.10.1开始不再提供自渲染广告位加载，后续会在新的分支实现，敬请期待。
> 5. Android依赖方式变更，查看[如何配置](SETUP.md)



## SDK对应版本

[[Android] 3.5.0.0](https://sf1-be-tos.pglstatp-toutiao.com/obj/union-platform/d8bcf772441c03541ab14c808536a802.zip)（理论上3.5+都支持）

[[iOS] 3.4.2.8](https://sf1-be-tos.pglstatp-toutiao.com/obj/union-platform/d93cdd1e574e09338f628a78fc808107.zip) （理论上3.4+都支持）

注：如果出现高版本不兼容问题，可联系我升级适配，或者使用上面指定版本。




## 官方文档（需要登陆）
- [Pangle Android SDK（Only support China traffic）](https://www.pangle.cn/union/media/union/download/detail?id=4&osType=android)
- [Pangle iOS SDK](https://www.pangle.cn/union/media/union/download/detail?id=16&osType=ios)


## 使用文档

- [参数文档](DOC_PROPERTY.md)



## 范例截图

<img src="https://cdn.jsdelivr.net/gh/nullptrX/assets/images/20210322143743.gif"/>



## 集成步骤

### 1. 添加yaml依赖
```yaml
dependencies:
  # 添加依赖
  pangle_flutter: latest
```
### 2. Android和iOS额外配置

- [基本配置入口](SETUP.md)


- iOS从版本3.4.1.9开始pod方式变更

  原话：【变更】pod方式变更，国内使用pod 'Ads-CN',海外使用pod 'Ads-Global'

  本项目默认集成`Ads-CN`， 如果你是国内APP，无需额外配置；如果你是海外APP，请参照如下配置：

  打开你flutter应用ios项目下的`Podfile`，在`target 'Runner do`上面添加如下代码即可（如果不熟悉Podfile，也可以参考本项目[example/ios/Podfile](example/ios/Podfile)里面的配置）。

  ```ruby
  # add code begin
  def flutter_install_ios_plugin_pods(ios_application_path = nil)
    # defined_in_file is set by CocoaPods and is a Pathname to the Podfile.
    ios_application_path ||= File.dirname(defined_in_file.realpath) if self.respond_to?(:defined_in_file)
    raise 'Could not find iOS application path' unless ios_application_path
  
    # Prepare symlinks folder. We use symlinks to avoid having Podfile.lock
    # referring to absolute paths on developers' machines.
  
    symlink_dir = File.expand_path('.symlinks', ios_application_path)
    system('rm', '-rf', symlink_dir) # Avoid the complication of dependencies like FileUtils.
  
    symlink_plugins_dir = File.expand_path('plugins', symlink_dir)
    system('mkdir', '-p', symlink_plugins_dir)
  
    plugins_file = File.join(ios_application_path, '..', '.flutter-plugins-dependencies')
    plugin_pods = flutter_parse_plugins_file(plugins_file)
    plugin_pods.each do |plugin_hash|
      plugin_name = plugin_hash['name']
      plugin_path = plugin_hash['path']
      if (plugin_name && plugin_path)
        symlink = File.join(symlink_plugins_dir, plugin_name)
        File.symlink(plugin_path, symlink)
  
        pod plugin_name, :path => File.join('.symlinks', 'plugins', plugin_name, 'ios')
        if plugin_name == 'pangle_flutter'
          # cn代表国内，global代表海外
          pod 'pangle_flutter/global', :path => File.join('.symlinks', 'plugins', plugin_name, 'ios')
        end
  
      end
    end
  end
  # add code end
  ```



## 使用说明

### 1. 信息流广告

<img src="https://github.com/nullptrX/assets/raw/static/pangle_flutter/images/feed_tip1.png" alt="pangle_flutter"  width="500" height="auto"/>

<img src="https://github.com/nullptrX/assets/raw/static/pangle_flutter/images/feed_tip2.png" alt="pangle_flutter" width="500" height="auto" />

###  2. iOS使用纯OC开发的项目导入该模块

1. 创建一个Swift文件，名称随意
2. 根据提示选择`Create Bridging Header`。如果没有提示，请自行搜索如何创建。

<img src="https://github.com/nullptrX/assets/raw/static/pangle_flutter/images/oc2swift.png" alt="OC导入Swift模块" width="500" height="auto" />




## 使用步骤

### 1. 初始化

```dart
import 'package:pangle_flutter/pangle_flutter.dart';
/// 如果在runApp方法调用之前初始化，加入下面这句代码
WidgetsFlutterBinding.ensureInitialized();
/// 初始化，未列出所有参数
/// [kAppId] 申请穿山甲广告位后得到的appID
await pangle.init(
  iOS: IOSConfig(appId: kAppId),
  android: AndroidConfig(appId: kAppId),
);
```



### 2. 开屏广告

```dart
/// 全屏类型
/// [kSplashId] 开屏广告ID, 对应Android的CodeId，对应iOS的slotID
await pangle.loadSplashAd(
  iOS: IOSSplashConfig(slotId: kSplashId, isExpress: false),
  android: AndroidSplashConfig(slotId: kSplashId, isExpress: false),
);


/// 自定义类型
/// 同Widget类用法
SplashView(
  iOS: IOSSplashConfig(slotId: kSplashId, isExpress: false),
  android: AndroidSplashConfig(slotId: kSplashId, isExpress: false),
  backgroundColor: Colors.white,
  /// 广告展示
  onShow: (){},
  /// 广告获取失败
  onError: (int code, String message){},
  /// 广告被点击
  onClick: (){},
  /// 广告被点击跳过
  onSkip: (){},
  /// 广告倒计时结束
  onTimeOver: (){},
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

基本覆盖了原生回调事件，现在点击右上角关闭[ x ]按钮，需要开发者手动移除，不再自动移除Item。

```dart
/// Banner通过PlatformView实现，使用方法同Widget
/// [kBannerId] Banner广告ID, 对应Android的CodeId，对应iOS的slotID
BannerView(
  iOS: IOSBannerAdConfig(slotId: kBannerId),
  android: AndroidBannerAdConfig(slotId: kBannerId),
  // 还有其他回调，具体可导入查看
),


// 必须限定范围大小，可用Expaned,Container,SizeBox,AspectRatio等
Container(
  height: 260,
  child: BannerView(
    iOS: IOSBannerConfig(
      slotId: kBannerExpressId600x260,
      expressSize: PangleExpressSize(width: 600, height: 260),
    ),
    android: AndroidBannerConfig(
      slotId: kBannerExpressId600x260,
      expressSize: PangleExpressSize(width: 600, height: 260),
    ),
    onBannerViewCreated: (BannerViewController controller){
      controller.updateTouchableBounds([Rect.zero]);
      controller.updateRestrictedBounds([Rect.zero]);
    },
    onClick: () {},
  ),
),
```

- 控制可点击区域（默认可点击）

```dart
// 因iOS的EXPRESS类型的广告内部使用WebView渲染，而WebView与FlutterView存在部分点击事件冲突，故提供该解决方案
onBannerViewCreated: (BannerViewController controller){
  // 禁止点击，传入一个Rect.zero即可
  controller.updateTouchableBounds([Rect.zero]);
  // 提供点击，传入空即可
  controller.updateTouchableBounds([]);

  // 额外不可点击区域（一般用于上面可点击范围上面，如可点击范围有一个悬浮按钮Widget）
  controller.updateRestrictedBounds([Rect.zero]);

},
```



### 5. 信息流广告

基本覆盖了原生回调事件，现在点击右上角关闭[ x ]按钮，需要开发者手动移除，不再自动移除Item。

- 获取信息流数据

```dart
/// 信息流实现逻辑
/// 首先进行网络请求，得到信息流数据
///
/// PangleFeedAd相应字段: 
/// [code] 响应码，0成功，-1失败
/// [message] 错误时，调试信息
/// [count] 获得信息流数量，一般同上面传入的count，最终结果以此count为主
/// [data] (string list) 用于展示信息流广告的键id
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
final items = Item(feedId: feedAdDatas[0]);
items.insert(Random().nextInt(items.length), item);
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

- 控制可点击区域（默认可点击）

```dart
// 因iOS的EXPRESS类型的广告内部使用WebView渲染，而WebView与FlutterView存在部分点击事件冲突，故提供该解决方案
// 1. 可点击区域key
final _bodyKey = GlobalKey();
// 不可点击区域key
final _otherKey = GlobalKey();
// 2.FeedView移动区域
Container(
  key: _bodyKey,
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      return _buildItem(index);
    },
)),
// 可能覆盖在FeedView上的button
FloatingActionButton(
  key: _otherKey,
),
// 3. 获取FeedViewController并限制点击范围
 AspectRatio(
   aspectRatio: 375 / 284.0,
   child: FeedView(
     id: item.feedId,
     onFeedViewCreated: (controller) {
       // 限制FeedView点击范围
       _initConstraintBounds(controller);
     },
     onDislike: (option) {
       // 移除FeedView两部曲
       pangle.removeFeedAd([item.feedId]);
       setState(() {
         items.removeAt(index);
       });
     },
   ),
 )

_initConstraintBounds(FeedViewController controller) {
  if (!Platform.isIOS) {
    return;
  }

  RenderBox bodyBox = _bodyKey.currentContext.findRenderObject();
  final bodyBound = PangleHelper.fromRenderBox(bodyBox);
  controller.updateTouchableBounds([bodyBound]);

  RenderBox otherBox = _otherKey.currentContext.findRenderObject();
  final otherBound = PangleHelper.fromRenderBox(otherBox);

  controller.updateRestrictedBounds([otherBound]);
}


// 4.清除缓存
// 可选，点击不喜欢即右上角叉时清除
pangle.removeFeedAd([item.feedId]);
// 必须
@override
void dispose() {
  /// 不关心返回值
  pangle.removeFeedAd(feedIds);
  /// 关心返回值
  /// _removeFeedAd();
  super.dispose();
}

/// 移除广告
_removeFeedAd() async {
  /// 返回移除个数
  int count = await pangle.removeFeedAd(feedIds);
  print('Feed Ad Removed: $count');
}

```



### 6. 插屏广告

```dart
 final result = await pangle.loadInterstitialAd(
   iOS: IOSInterstitialAdConfig(
     slotId: kInterstitialId

     /// 该宽高为你申请的广告位宽高，请根据实际情况赋值
     expressSize: PangleExpressSize(width: width, height: height),
   ),
   android: AndroidInterstitialAdConfig(
     slotId: kInterstitialId,
   ),
 );
print(jsonEncode(result));
```



## 开发说明

1. iOS信息流广告的点击事件需要传入`rootViewController`，使用的是`(UIApplication.shared.delegate?.window??.rootViewController)!`，暂未发现问题。
4. `BannerView`、`FeedView`通过[`Hybrid Composition`](https://github.com/flutter/flutter/wiki/Hybrid-Composition)实现。在安卓上，`PlatformView`最低支持API 19。

 

## 贡献

- 有任何更好的实现方式或增加额外的功能，提交PR。
- 有任何使用上的问题，提交issue。



## 交流

提交issue即可。

