## 1.9.5
- Fix analysis issues.

## 1.9.4
- Fix analysis issues.

## 1.9.3
- Fix analysis issues.

## 1.9.2
- Fix [#87], deprecated method.

## 1.9.1
- Optimize README (Clickthrough)

## 1.9.0
- Fix click through problem on iOS
- Remove "updateTouchableBounds" & "updateRestrictedBounds"
- Add "addTouchableBounds" & "clearTouchableBounds" (extra click areas)

## 1.8.0
- Adapt pangle SDK 4.7+ (Android & iOS)
- [SplashView] Remove "onSkip" & "onTimeOver", add "onClose"
- [SplashView] Fix "expressSize" not working on Android

## 1.7.0

- Adapt pangle SDK 4.6+ (Android & iOS)
- Adapt flutter 3.0.0
- Add getDeviceInfo method

## 1.6.0

- Adapt pangle SDK 4.3+ (Android & iOS)
- Delete the splashButtonType param in AndroidSplashConfig and IOSSplashConfig
- Delete the downloadType param in config_android.dart
- Add gdpr,idfa params (IOSConfig)
- Add openGDPRPrivacy method (iOS)

## 1.5.0+1

- Release

## 1.5.0+1-beta

- Add useHybridComposition param (AndroidSplashView, AndroidBannerView, AndroidFeedView)

## 1.5.0-beta

- Update ad sdk
    - Android: Delete the rewardName and rewardAmount params in AndroidRewardedVideoConfig
    - iOS: Delete the isPaidApp param in IOSConfig

## 1.4.7

- Fix the type conversion problem in FLTSplashView

## 1.4.6

- The useTextureView property defaults to true (pangle.init(...))
- Optimize gradle dependency library version limit
- Added callbacks for interstitial, full-screen video, and rewarded video events

## 1.4.5

- Fixed the issue that the onLoad of SplashView in iOS does not call back
- Fix that the initialization parameter isPaidApp in iOS was incorrectly written as coppa
- Optimized the problem that SplashView in iOS cannot adapt to the screen size due to the SDK upgrade, and added PangleExpressSize to configure the display size

## 1.4.4

- Add `onLoad` callback for SplashView when an ad is loaded.

## 1.4.3

- Downgrade kotlin's version

## 1.4.2

- Migrating the plugin to the V2 embedding

## 1.4.1

- Fix splashButtonType not work(IOSSplashConfig)

## 1.4.0

- Upgrade android sdk version to 3.9.0.5, upgrade ios sdk version to 3.9+
- Add new option for requesting ads(clickable area & downloading type popup dialog)

## 1.3.0

- Upgrade android sdk version to 3.9.0.0, upgrade ios sdk version to 3.8+
- Remove open_ad_sdk module, use maven repository instead of aar package
- Optimize example

## 1.2.0

- Adapt ads sdk(Android 3.8.0.0, iOS 3.7.0.5)
- Fix FeedView's onDislike not callback on iOS

## 1.1.0

- Adapt pangle overseas android sdk

## 1.0.1

- Solve build packages failed (remove unrelated files)

## 1.0.0

- null-safety

## 0.10.1

- Remove Self-rendering ads support（Remove parameter `isExpress`）
- Optimize loading rewarded video & fullscreen video ads
- Fix #20
- Refactor `BannerView`, `FeedView`, `SplashView`
- Add `pangle.removeFeedAd()` interface (Remove caches of feed ads)

## 0.9.1

* Adapt to open_ad_sdk 3.5.0.0 for Android. iOS are not affected

## 0.8.2

* Fix property `tolerateTimeout` type cast error
* Fix example's Podfile has not  joined plugin `pangle_flutter`

## 0.8.1

* Adapt to pangle sdk 3.4+ (part class is removed, part of the property is out of date)
* PangleResult add property `verify`

## 0.7.1

* Upgrade min dependency version of `Bytedance-UnionAD`  to 3.3

## 0.6.5

* Adapt to onRewardVerify/nativeExpressRewardedVideoAdServerRewardDidSucceed callback parameters for reward video

## 0.6.4

* Fix exception when BannerView & FeedView `dispose`

## 0.6.3

* Optimize static analysis

## 0.6.2

* Support custom splash ads [#10]
* Upgrade pangle sdk

## 0.6.1

* Fix rendering banner more than 5 seconds
* Rename `PangleFeedAd` to `PangleAd`
* Add `interval` for `BannerView`

## 0.5.1

* Remove `loadAwait` 
* Adapt to `open_ad_sdk 3.3.0.0` 
* Podspec uses  `'Bytedance-UnionAD', '~>3.2'` 

## 0.4.3

* Add click action conflict solution for iOS
* Add callback for splash ads
* Fix bugs

## 0.4.2

* Adds `isUserInteractionEnabled` attribute for iOS config
* Fix rewarded video & fullscreen video callback crashed on Android.

```dart
FeedView(
  id: item.feedId,
  /// disable touch
  isUserInteractionEnabled: false,
)
```

## 0.4.1

* Breaking changes.
* Replace method returning type ` Map` to `PangleResult` 
* Support iOS 14 for request tracking authorization

## 0.3.6

* Fix feed express view for ios not works.

## 0.3.5

* Refactor Android & iOS implementation.
* Fix the memory leak of loading rewarded video ads & fullscreen video ads.
* Optimize callback messages for requesting various ads.

## 0.3.4

* On flutter android sdk, support `registerWith` method  to load this plugin.
* Rename `loadRewardVideoAd` to `loadRewardedVideoAd`.

## 0.3.3

* Remove third party image loading framework dependency from Android & iOS.

## 0.3.2

* Downgrade `Bytedance-UnionAD` to `v3.2.5.1`.

## 0.3.1

* Adapt `open_ad_sdk`to `v3.2.5.1`.
* Fix sdk printing a lot of log issue. (#7)

## 0.2.1

* Update `Bytedance-UnionAD` to `v3.2.5.1`.
* Update `open_ad_sdk` to `v3.2.5.0`.
* New expressSize parameter to request ads. ()（The previous releases make ads dislocation & rendering incompletely ）
* Fix `BannerView`、`FeedView`  touch events not work on iOS.

## 0.1.11

* Splash ads `loadAwait` function.
* Interestitial ads callbacks after closing.

## 0.1.10

* Support setting the size of feed express ads, banner ads.

## 0.1.9

* Fix the height of ConstraintLayout's  Group widget not working.

## 0.1.8

* Optimize `BannerView`, makes its config null safety.
* Use new config class name.

## 0.1.7

* Fix rewarded video ads callback not works.
* Support fullscreen video ads.

## 0.1.6

* Fix feed ads showing incorrect height.
* Support preloading rewarded video ads.

## 0.1.5

* Refactor the ads loading logic of iOS.
* Support splash express ads (No test), rewarded video express ads.

## 0.1.4

* Fix feed ads loading issue on Android.

## 0.1.3

* Support express feed ads.
* Optimize `BannerView`,`FeedView` (Using `GlobalObjectKey` to prevent destroying `PlatformView` ).

## 0.1.2

* Support template rendering of interstitial ads & banner ads.
* Optimize `BannerView`, `FeedView` removing logic.

## 0.1.1

* Add interstitial ads.
* Make android native permission request deprecated.

## 0.0.6

* Remove the weak reference call of `FlutterResult`.


## 0.0.5

* Add the default implemention of removing  `FeedView`, `BannerView`.


## 0.0.4

* Use `ConstraintLayout`  to layout ads on Android.
* Optimize `FeedView`, `BannerView`  loading logic.


## 0.0.3

* Formats project files.


## 0.0.2

* Fixes the issues of `Dart Analysis`.


## 0.0.1

* Init `Splash Ads`, `Rewarded Video Ads`, `Banner Ads`, `Feed Ads`.



