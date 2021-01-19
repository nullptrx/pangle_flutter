# 穿山甲 Flutter SDK

[![pub package](https://img.shields.io/pub/v/pangle_flutter.svg)](https://pub.dartlang.org/packages/pangle_flutter) [![Licence](https://img.shields.io/github/license/nullptrX/pangle_flutter)](https://github.com/nullptrX/pangle_flutter/blob/master/LICENSE) [![flutter](https://img.shields.io/badge/flutter-1.22.5-green)](https://flutter.dev/docs/get-started/install) 



## 简介

`pangle_flutter`是一款集成了穿山甲 Android 和 iOS SDK的Flutter插件。部分代码由官方范例修改而来。

- [Android Demo](https://github.com/bytedance/pangle-sdk-demo)
- [iOS Demo](https://github.com/bytedance/Bytedance-UnionAD)



## 官方文档（需要登陆）
- [Pangle Android SDK（Only support China traffic）](https://www.pangle.cn/union/media/union/download/detail?id=4&osType=android)
- [Pangle iOS SDK](https://www.pangle.cn/union/media/union/download/detail?id=16&osType=ios)


## 使用文档

- [参数文档](DOC_PROPERTY.md)


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
  
        if plugin_name == 'pangle_flutter'
            # cn代表国内，global代表海外
            pod 'pangle_flutter/global', :path => File.join('.symlinks', 'plugins', plugin_name, 'ios')
        else
            pod plugin_name, :path => File.join('.symlinks', 'plugins', plugin_name, 'ios')
        end
      end
    end
  end
  ```



## 使用说明

目前iOS类信息流广告和横幅广告还处于预览版，部分功能存在不能正常使用的情况（如点击事件传递问题，渲染慢），不建议用于正式环境

### 1. 信息流广告

1. 原生自渲染信息流广告： 指定图片大小或比例固定，由开发者根据imageMode自行渲染。
模板渲染广告：指定整个广告宽高，由SDK自动适配传入的宽高进行渲染。
2. 原生自渲染信息流广告本模块暂不能整个item自定义宽高，只能使用`PangleImgSize`中的值指定图片宽高比例，模版渲染广告可指定期望宽高，但必须跟广告后台说明的宽高对应。
3. 目前根据SDK Demo所知，模板类广告每次只能传入一种模板宽高，并且渲染广告时获取不到该广告所使用的模板类型。因此如果选择多种模板，可能导致渲染出来的效果不佳。

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
  onError: (){},
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

```dart
/// Banner通过PlatformView实现，使用方法同Widget
/// [kBannerId] Banner广告ID, 对应Android的CodeId，对应iOS的slotID
BannerView(
  iOS: IOSBannerAdConfig(slotId: kBannerId),
  android: AndroidBannerAdConfig(slotId: kBannerId),
),
```

- 切换可点击状态

```dart
// 因iOS的EXPRESS类型的广告内部使用WebView渲染，而WebView与FlutterView存在部分点击事件冲突，故提供该解决方案
final _bannerKey = GlobalKey<BannerViewState>();
// 外部控制该广告位是否可点击
_bannerKey.currentState.setUserInteractionEnabled(enable);
```



### 5. 信息流广告

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

- 切换是否可点击状态

```dart
// 因iOS的EXPRESS类型的广告内部使用WebView渲染，而WebView与FlutterView存在部分点击事件冲突，故提供该解决方案
// 1. 继承GlobalObjectKey实现自己的key
class _ItemKey extends GlobalObjectKey<FeedViewState> {
  _ItemKey(Object value) : super(value);
}
// 2. 为FeedView提供自己的key
FeedView(
  key: _ItemKey(item.feedId),
  ...
)
// 3. 为需要计算位置的Widget提供key, 如
final _titleKey = GlobalKey();
AppBar(key: _titleKey)
final _naviKey = GlobalKey();
BottomNavigationBar(key: _naviKey)
// 4. 为FeedView容器提供ScrollController, 如
final _controller = ScrollController();
ListView(controller: _controller)
// 5. 监听controller滚动事件，并动态切换可点击状态
@override
void initState() {
  super.initState();
  _loadFeedAd();
  _controller.addListener(_onScroll);
}

@override
void dispose() {
  _controller.removeListener(_onScroll);
  super.dispose();
}
_onScroll() {
  if (!Platform.isIOS) {
    return;
  }

  RenderBox titleBox = _titleKey.currentContext.findRenderObject();
  var titleSize = titleBox.size;
  var titleOffset = titleBox.localToGlobal(Offset.zero);

  final minAvailableHeigt = titleOffset.dy + titleSize.height;

  RenderBox naviBox = _naviKey.currentContext.findRenderObject();
  var naviOffset = naviBox.localToGlobal(Offset.zero);

  final maxAvailableHeight = naviOffset.dy;

  /// 检测各个item的宽高、偏移量是否满足点击需求
  for (var value in feedIds) {
    _switchUserInteraction(maxAvailableHeight, minAvailableHeigt, value);
  }
}

void _switchUserInteraction(
  double maxAvailableHeight,
  double minAvailableHeigt,
  String id,
) {
  var itemKey = _ItemKey(id);
  RenderBox renderBox = itemKey.currentContext.findRenderObject();
  var size = renderBox.size;
  var offset = renderBox.localToGlobal(Offset.zero);

  /// 最底部坐标不低于NavigationBar, 最顶部不高于AppBar
  var available = offset.dy + size.height < maxAvailableHeight &&
    offset.dy > minAvailableHeigt;
  itemKey.currentState.setUserInteractionEnabled(available);
}
  

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
   ),
 );
print(jsonEncode(result));
```



## 开发说明

1. 开屏广告放在runApp之前调用体验最佳
3. iOS信息流广告的点击事件需要传入`rootViewController`，使用的是`(UIApplication.shared.delegate?.window??.rootViewController)!`，暂未发现问题。

4. `BannerView`、`FeedView`通过`PlatformView`实现。在安卓上，`PlatformView`最低支持API 20。



## 贡献

- 有任何更好的实现方式或增加额外的功能，欢迎提交PR。
- 有任何使用上的问题，欢迎提交issue。



## 交流

因微信群7日有效期，就不放微信群二维码了。备注项目名加我好友，加入微信交流群。

备注：`pangle_flutter`

<img src="https://github.com/nullptrX/assets/raw/static/pangle_flutter/images/qrcode.png" alt="Flutter开发交流" width="300" height="100%" />

