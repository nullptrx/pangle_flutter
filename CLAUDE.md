# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`pangle_flutter` is a Flutter plugin wrapping ByteDance's Pangle (穿山甲) ad SDK for Android and iOS. It supports Splash, Rewarded Video, Fullscreen Video, Feed, Feed Icon, Banner, Draw, Stream, and EcMall ads via `MethodChannel` and `EventChannel`, plus `PlatformView`-based ad widgets.

## Commands

```bash
# Get dependencies
flutter pub get

# Analyze (enforces strict linting — see analysis_options.yaml)
flutter analyze

# Run tests
flutter test

# Run a single test
flutter test test/pangle_flutter_test.dart

# Run the example app (must cd into example first)
cd example && flutter run

# Validate podspec (iOS)
pod lib lint ios/pangle_flutter.podspec
```

## Architecture

### Dart layer (`lib/`)

- **`lib/pangle_flutter.dart`** — barrel export for the public API.
- **`lib/src/pangle_plugin.dart`** — singleton `pangle` instance of `PanglePlugin`. All imperative ad calls go through the `MethodChannel` (`nullptrx.github.io/pangle`). Event callbacks use `EventChannel` (`nullptrx.github.io/pangle_event`).
  - Init: `init`
  - Splash: `loadSplashAd`
  - Feed: `loadFeedAd`, `removeFeedAd`, `loadFeedIconAd`
  - Draw: `loadDrawAd`, `removeDrawAd`
  - Stream: `loadStreamAd`
  - Rewarded video: `loadRewardedVideoAdOnly`, `showRewardedVideoAd`, `hasRewardedVideoAd`, `rewardedVideoEventStream`
  - Fullscreen video: `loadFullscreenVideoAdOnly`, `showFullscreenVideoAd`, `hasFullscreenVideoAd`, `fullscreenEventStream`
  - Device/SDK: `getSdkVersion`, `getAndroidDeviceInfo`, `getIOSDeviceInfo`, `requestPermissionIfNecessary`, `requestTrackingAuthorization`, `getTrackingAuthorizationStatus`, `getThemeStatus`, `setThemeStatus`
- **`lib/src/config_android.dart`** — `AndroidConfig`, `AndroidSplashConfig`, `AndroidBannerConfig`, `AndroidFeedConfig`, `AndroidFeedIconConfig`, `AndroidRewardedVideoConfig`, `AndroidFullscreenVideoConfig`, `AndroidDrawConfig`, `AndroidStreamConfig` — serialize to JSON via `.toJSON()`.
- **`lib/src/config_ios.dart`** — `IOSConfig`, `IOSSplashConfig`, `IOSBannerConfig`, `IOSFeedConfig`, `IOSRewardedVideoConfig`, `IOSFullscreenVideoConfig`, `IOSDrawConfig`, `IOSStreamConfig`.
- **`lib/src/ad/`** — `RewardedAd`, `RewardedAdPool`, `FullscreenAd`, `FullscreenAdPool`, `AdState`, `AdEvent`.
- **`lib/src/view/`** — `PlatformView`-based ad widgets. Each type follows the same pattern:
  - `<type>view.dart` — public `StatefulWidget` with iOS/Android config fields and callbacks.
  - `<type>/platform_interface.dart` — abstract platform interface.
  - `<type>/<type>view_android.dart` — uses `SurfaceAndroidPlatformView`.
  - `<type>/<type>view_android_legacy.dart` — uses `AndroidView` (virtual display) for older hybrid composition.
  - `<type>/<type>view_ios.dart` — wraps `UiKitView`.
  - `<type>/<type>view_method_channel.dart` — `MethodChannel`-backed controller.
  - `platform_controller.dart` — base `ViewController` with `addTouchableBounds` / `clearTouchableBounds` for iOS click-through.
  - **Widgets:** `BannerView`, `FeedView`, `SplashView`, `DrawView`, `EcMallView`.

### Android layer (`android/`)

- **`PangleFlutterPlugin.kt`** — registers method channel handlers, view factories (`BannerViewFactory`, `FeedViewFactory`, `SplashViewFactory`, `DrawViewFactory`, `EcMallViewFactory`), and event stream handler.
- **`PangleAdManager.kt`** — handles all `MethodChannel` calls: SDK init, ad loading.
- **`PangleAdSlotManager.kt`** — ad slot management.
- **`delegate/FLT*.kt`** — per-ad-type delegates: `FLTBannerExpressAd`, `FLTFeedExpressAd`, `FLTFullScreenVideoAd`, `FLTInterstitialAd`, `FLTNativeExpressAd`, `FLTRewardedVideoAd`, `FLTSplashAd`.
- **`view/Flutter*.kt`** — `PlatformView` implementations: `FlutterBannerView`, `FlutterFeedView`, `FlutterSplashView`, `FlutterDrawView`, `FlutterEcMallView`.
- **`dialog/`** — `AdDialog`, `NativeSplashDialog`, `SupportSplashDialog`.
- Dependencies: `com.pangle.cn:ads-sdk-pro:[7.0,8.0)` from `https://artifact.bytedance.com/repository/pangle`. Min SDK: 24.

### iOS layer (`ios/`)

- **`SwiftPangleFlutterPlugin.swift`** — entry point; registers method channel, event channel, and view factories.
- **`PangleAdManager.swift`** — handles method calls mirroring the Android side.
- **`FLTBannerView.swift` / `FLTFeedView.swift` / `FLTSplashView.swift` / `FLTDrawView.swift` / `FLTEcMallView.swift`** — `FlutterPlatformView` implementations.
- **`PangleEventStreamHandler.swift`** — `FlutterStreamHandler` for the event channel.
- **`delegate/`** — `FLTRewardedVideoExpressAd`, `FLTFullscreenVideoExpressAd`, `FLTInterstitialExpressAd`, `FLTNativeExpressAd`, `FLTSplashAd`, `FLTStreamAd`.
- **`task/`** — ad task protocol and per-type task implementations.
- Dependency: `Ads-CN ~> 7.0` (pod). iOS minimum: 13.0, Swift 5.9.

### Key design notes

- All ad configs take separate `ios:` and `android:` named parameters; the plugin selects the correct one at runtime via `Platform.isIOS` / `Platform.isAndroid`.
- Feed/Draw ads use a two-step flow: `loadFeedAd()` / `loadDrawAd()` returns string IDs → pass IDs to `FeedView(id:)` / `DrawView(id:)` widgets → call `removeFeedAd(ids)` / `removeDrawAd(ids)` in `dispose()`.
- `BannerView`, `FeedView`, `SplashView`, `DrawView`, `EcMallView` must be wrapped in a size-constraining widget (`Container`, `SizedBox`, `AspectRatio`, `Expanded`).
- Click-through on iOS is handled via `addTouchableBounds` / `clearTouchableBounds` on the view controller.
- Rewarded and fullscreen video use a preload-then-show pattern via ad pool classes in `lib/src/ad/`.
