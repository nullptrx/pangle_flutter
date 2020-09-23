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
* Replaces method returning type ` Map` to `PangleResult` 
* Supports iOS 14 for request tracking authorization

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

* Supports setting the size of feed express ads, banner ads.

## 0.1.9

* Fix the height of ConstraintLayout's  Group widget not working.

## 0.1.8

* Optimizes `BannerView`, makes its config null safety.
* Use new config class name.

## 0.1.7

* Fix rewarded video ads callback not works.
* Supports fullscreen video ads.

## 0.1.6

* Fix feed ads showing incorrect height.
* Supports preloading rewarded video ads.

## 0.1.5

* Refactors the ads loading logic of iOS.
* Supports splash express ads (No test), rewarded video express ads.

## 0.1.4

* Fixes feed ads loading issue on Android.

## 0.1.3

* Supports express feed ads.
* Optimizes `BannerView`,`FeedView` (Using `GlobalObjectKey` to prevent destroying `PlatformView` ).

## 0.1.2

* Supports template rendering of interstitial ads & banner ads.
* Optimizes `BannerView`, `FeedView` removing logic.

## 0.1.1

* Adds interstitial ads.
* Makes android native permission request deprecated.

## 0.0.6

* Removes the weak reference call of `FlutterResult`.


## 0.0.5

* Adds the default implemention of removing  `FeedView`, `BannerView`.


## 0.0.4

* Uses `ConstraintLayout`  to layout ads on Android.
* Optimizes `FeedView`, `BannerView`  loading logic.


## 0.0.3

* Formats project files.


## 0.0.2

* Fixes the issues of `Dart Analysis`.


## 0.0.1

* Init `Splash Ads`, `Rewarded Video Ads`, `Banner Ads`, `Feed Ads`.




