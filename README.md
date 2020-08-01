# 穿山甲 Flutter SDK

[![pub package](https://img.shields.io/pub/v/pangle_flutter.svg)](https://pub.dartlang.org/packages/pangle_flutter)

## 简介

pangle_flutter是一款集成了穿山甲`Android`和`iOS`SDK的Flutter插件。其中部分代码由官方demo修改而来。

- [Android Demo](https://github.com/bytedance/pangle-sdk-demo)
- [iOS Demo](https://github.com/bytedance/Bytedance-UnionAD)

## 官方文档（需要登陆）
- [穿山甲 Android SDK（Only support China traffic）](https://ad.oceanengine.com/union/media/union/download/detail?id=4&osType=android)

- [穿山甲 iOS SDK](https://ad.oceanengine.com/union/media/union/download/detail?id=16&osType=ios)

## 集成步骤

### Android



On iOS the WebView widget is backed by a [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview);
On Android the WebView widget is backed by a [WebView](https://developer.android.com/reference/android/webkit/WebView).

## Developers Preview Status
The plugin relies on Flutter's new mechanism for embedding Android and iOS views.
As that mechanism is currently in a developers preview, this plugin should also be
considered a developers preview.

Known issues are tagged with the [platform-views](https://github.com/flutter/flutter/labels/a%3A%20platform-views) and/or [webview](https://github.com/flutter/flutter/labels/p%3A%20webview) labels.

To use this plugin on iOS you need to opt-in for the embedded views preview by
adding a boolean property to the app's `Info.plist` file, with the key `io.flutter.embedded_views_preview`
and the value `YES`.

## Keyboard support - not ready for production use
Keyboard support within webviews is experimental. The Android version relies on some low-level knobs that have not been well tested
on a broad spectrum of devices yet, and therefore **it is not recommended to rely on webview keyboard in production apps yet**.
See the [webview-keyboard](https://github.com/flutter/flutter/issues?q=is%3Aopen+is%3Aissue+label%3A%22p%3A+webview-keyboard%22) for known issues with keyboard input.

## Setup

### iOS
Opt-in to the embedded views preview by adding a boolean property to the app's `Info.plist` file
with the key `io.flutter.embedded_views_preview` and the value `YES`.

## Usage
Add `webview_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

You can now include a WebView widget in your widget tree.
See the WebView widget's Dartdoc for more details on how to use the widget.