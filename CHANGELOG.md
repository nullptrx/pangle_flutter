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



