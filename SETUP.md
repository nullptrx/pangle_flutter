## 集成步骤

首先，去官网下载SDK。



### Android



#### 1. 导入依赖

- Module方式

>1. 导入AAR module
>
>2. 创建一个新module，`File->New->New Module...->Import .JAR/AAR Package`，选择`open_ad_sdk.aar`完成导入。
>
>3. 在`app`目录下build.gradle中，添加依赖
>
>   ```groovy
>   dependencies {
>       implementation project(':open_ad_sdk')
>   }
>   ```



- Maven仓库依赖方式

> 在`app`目录下build.gradle中，添加依赖
>
> ```groovy
> dependencies {
>   	// 添加依赖
>     implementation 'io.github.nullptrx:pangle:3.5.0.3@aar'
> }
> 
> repositories {
>     google()
>     jcenter()
>     // 添加仓库地址（这是我托管在github上的仓库，版本md5与原sdk一致，请放心使用）
>     maven { url 'https://cdn.jsdelivr.net/gh/nullptrX/repo/m2/' }
> }
> ```






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

默认使用pod导入



#### 2. 工程plist文件设置

- 另官方文档提示：SDK API 已经全部支持HTTPS，但是广告主素材存在非HTTPS情况。所以需要支持http协议正常使用。

```xml
<dict>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
```



#### 3.剩余配置参考官方文档

[Xcode配置](https://ad.oceanengine.com/union/media/union/download/detail?id=16&docId=5de8d570b1afac00129330c5&osType=ios)

文档中提到的`添加依赖库`的相关说明，如果你是用Pod管理依赖库，则不需手动导入；反之，则需手动导入。
