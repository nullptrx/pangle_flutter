## 集成步骤

首先，当然是去官网下载SDK了。(做了几张GIF图，效果不太好，还是文字说明吧～)



### Android



#### 1. 导入AAR包

##### ~~方法一~~(已移除该方式导入的支持)

1. ~~将压缩包中的`open_ad_sdk.aar`拷贝至module `app`中`libs`文件夹中（没有就创建一个）。~~
2. ~~在module `app`的`build.gradle`中对应位置加人如下配置~~

```groovy
android {
// 1. 添加aar目录
repositories {
        flatDir {
            dirs('libs')
        }
    }
}

dependencies {
    // 2. 导入open_ad_sdk
    implementation(name: 'open_ad_sdk', ext: 'aar')

}
```

##### 方法二 （推荐）

创建一个新module，`File->New->New Module...->Import .JAR/AAR Package`，选择`open_ad_sdk.aar`完成导入。




#### 2. 处理AndroidManifest错误

官方AAR中application节点加了label属性，所以需要覆盖它

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    # 还有这句
    xmlns:tools="http://schemas.android.com/tools"
    package="io.github.nullptrx.pangleflutterexample">
  
    <application
        android:name="io.flutter.app.FlutterApplication"
        android:icon="@mipmap/ic_launcher"
        android:label="Pangle Flutter"
        # 添加下面这句
        tools:replace="android:label"
     >
```



#### 3. 因部分广告请求是http请求，在安卓API 24以上需要手动添加http支持，才能正常请求广告

```xml
 <application
        android:name="io.flutter.app.FlutterApplication"
        android:icon="@mipmap/ic_launcher"
        android:label="Pangle Flutter"
        # 添加下面这句
        android:networkSecurityConfig="@xml/pangle_network_config"
        # 或者直接允许所有http请求
        android:usesCleartextTraffic=“true”
        # 以上二选一      
        tools:replace="android:label">

```



#### 4. 至此，Android模块一般可以正常使用了。（权限、混淆等配置均已在模块中，无需额外配置）



### iOS



#### 1. 导入Framework包（无需操作）

默认使用pod导入，在4.x版本以内会使用最新版本



#### 2. 工程plist文件设置

- 因信息流、Banner广告使用了PlatformView，所以需要在app的`Info.plist` 中加入键 `io.flutter.embedded_views_preview` ，值`YES`。
- 另官方文档提示：SDK API 已经全部支持HTTPS，但是广告主素材存在非HTTPS情况。所以需要支持http协议正常使用。

```xml
<dict>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>io.flutter.embedded_views_preview</key>
    <true/>
</dict>
```



#### 3.剩余配置参考官方文档

[Xcode配置](https://ad.oceanengine.com/union/media/union/download/detail?id=16&docId=5de8d570b1afac00129330c5&osType=ios)

文档中提到的`添加依赖库`的相关说明，如果你是用Pod管理依赖库，则不需手动导入；反之，则需手动导入。
