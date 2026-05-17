# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`pangle_flutter` is a Flutter plugin wrapping ByteDance's Pangle (穿山甲) ad SDK for Android and iOS. It supports Splash, Rewarded Video, Fullscreen Video, Feed, Banner, and Interstitial ads via `MethodChannel` and `EventChannel`, plus `PlatformView`-based ad widgets.

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
- **`lib/src/pangle_plugin.dart`** — singleton `pangle` instance of `PanglePlugin`. All imperative ad calls (init, loadSplashAd, loadRewardedVideoAd, loadFeedAd, removeFeedAd, loadFullscreenVideoAd, etc.) go through the `MethodChannel` (`nullptrx.github.io/pangle`) here. Event callbacks use `EventChannel` (`nullptrx.github.io/pangle_event`) with `PangleEventType` indices.
- **`lib/src/config_android.dart` / `config_ios.dart`** — per-platform config classes (`AndroidConfig`, `IOSConfig`, `AndroidBannerConfig`, `IOSBannerConfig`, etc.) that serialize to JSON maps via `.toJSON()`.
- **`lib/src/view/`** — `PlatformView`-based ad widgets. Each ad type (Banner, Feed, Splash) follows the same pattern:
  - `<type>view.dart` — public `StatefulWidget` with iOS/Android config fields and callback properties. Delegates rendering to a `BannerViewPlatform`/`FeedViewPlatform`/`SplashViewPlatform` instance.
  - `<type>/platform_interface.dart` — abstract platform interface and callbacks handler interface.
  - `<type>/<type>view_android.dart` — `AndroidBannerView` (uses `SurfaceAndroidPlatformView` / `ExpressAndroidPlatformView`).
  - `<type>/<type>view_android_legacy.dart` — uses virtual display (`AndroidView`) for older hybrid composition.
  - `<type>/<type>view_ios.dart` — wraps `UiKitView`.
  - `<type>/<type>view_method_channel.dart` — `MethodChannel`-backed controller for calling native view methods.
  - `platform_controller.dart` — base `ViewController` with `addTouchableBounds` / `clearTouchableBounds` for iOS click-through handling.

### Android layer (`android/`)

- **`PangleFlutterPlugin.kt`** — registers method channel handlers, view factories (`BannerViewFactory`, `FeedViewFactory`, `SplashViewFactory`, `NativeBannerViewFactory`), and event stream handler.
- **`PangleAdManager.kt`** — handles all `MethodChannel` calls: SDK init, ad loading (splash, rewarded video, feed, interstitial, fullscreen video).
- **`delegate/FLT*.kt`** — per-ad-type delegates that call Pangle SDK and respond via `MethodChannel.Result`.
- **`view/Flutter*.kt`** — `PlatformView` implementations rendering native Pangle ad views.
- Dependencies: `com.pangle.cn:ads-sdk-pro:[5.4,5.5)` from `https://artifact.bytedance.com/repository/pangle`.

### iOS layer (`ios/`)

- **`SwiftPangleFlutterPlugin.swift`** — entry point; registers method channel, event channel, and view factories.
- **`PangleAdManager.swift`** — handles method calls mirroring the Android side.
- **`FLTBannerView.swift` / `FLTFeedView.swift` / `FLTSplashView.swift`** — `FlutterPlatformView` implementations.
- **`PangleEventStreamHandler.swift`** — `FlutterStreamHandler` for the event channel.
- Dependency: `Ads-CN ~> 5.1` (pod). iOS minimum: 9.0, Swift 5.0.

### Key design notes

- All ad configs take separate `iOS:` and `android:` named parameters; the plugin selects the correct one at runtime via `Platform.isIOS` / `Platform.isAndroid`.
- Feed ads use a two-step flow: `loadFeedAd()` returns string IDs → pass IDs to `FeedView(id:)` widgets → call `removeFeedAd(ids)` in `dispose()`.
- BannerView, FeedView, and SplashView must be wrapped in a size-constraining widget (`Container`, `SizedBox`, `AspectRatio`, `Expanded`).
- Click-through on iOS is handled via `addTouchableBounds` / `clearTouchableBounds` on the view controller.
- `loadInterstitialAd` is deprecated; use `loadFullscreenVideoAd` instead.
