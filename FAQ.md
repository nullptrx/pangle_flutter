[English](#english) | [中文](#中文)

---

## English

# FAQ & Technical Decisions

This document explains the rationale behind non-obvious implementation choices introduced in v3.0.0, so contributors and users understand _why_, not just _what_ changed.

---

### Q1 — Why are there now two separate error callbacks for SplashView?

**Before v3.0.0**, both load failure and render failure fired the same `onError` callback, making it impossible to distinguish them on the Dart side.

**From v3.0.0**, `SplashView` has two distinct callbacks — consistent with the existing `BannerView` pattern:

| Callback | When it fires |
|---|---|
| `onError(code, message)` | The ad **failed to load** (network error, no fill, timeout, etc.) |
| `onRenderFail(code, message)` | The ad loaded successfully but **failed to render** (template rendering error) |

**Migration:** If you were using `onError` to catch all splash failures, add an `onRenderFail` handler alongside it. The `onError` semantics are unchanged.

```dart
SplashView(
  // ...
  onError: (code, msg) {
    // Load failed — show fallback UI, retry, etc.
  },
  onRenderFail: (code, msg) {
    // Render failed — the ad was fetched but could not be displayed
  },
)
```

---

### Q2 — What happened to the FlutterOverlayView click-penetration fix on iOS?

**Background**

In older Flutter (Hybrid Composition mode), when a Flutter widget was drawn over a native platform view (ad), touch routing could go wrong: the `FlutterOverlayView` that Flutter inserted to draw above the native view had `userInteractionEnabled = NO`, so taps "fell through" to the native ad underneath even when the user intended to tap a Flutter widget on top.

The workaround (described in [this article](http://jackin.cn/2021/02/01/bytedance-ad-click-penetration-on-flutter.html)) was to override `hitTest` on the native view container, detect `FlutterOverlayView` by class name, and return `nil` to block the touch if the overlay was covering the ad.

**Why it was removed in v3.0.0**

Flutter 3.0 switched Android platform views to **Texture Layer Hybrid Composition (TLHC)** as the default rendering mode. In TLHC, Flutter no longer inserts `FlutterOverlayView` into the view hierarchy at all — the native view's content is streamed into Flutter's render pipeline via a `SurfaceTexture`. As a result:

- `findTargetOverlayView` traversed the view hierarchy looking for a view whose class name was `"FlutterOverlayView"`
- In TLHC mode that view never exists, so the function always returned `nil`
- `isOverlay(targetView, nil)` always returned `false`
- The entire `hitTest` block was skipped and `super.hitTest` was called unconditionally
- **The mechanism was a silent no-op on every Flutter 3+ app**

Additionally, the class-name detection (`String(describing: view.classForCoder) == "FlutterOverlayView"`) is fragile — it relies on Flutter's internal private class name, which could change in any engine release without notice.

**What replaced it**

The `hitTest` override was simplified to only honour `touchableBounds`:

```swift
override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard isUserInteractionEnabled, !isHidden, alpha >= 0.01 else { return nil }

    // If touchableBounds are set, restrict which areas forward touches to the native view.
    // All other touches pass through to Flutter widgets underneath.
    if !touchableBounds.isEmpty {
        let windowPoint = self.convert(point, to: keyWindow)
        let isTouchable = touchableBounds.contains { $0.contains(windowPoint) }
        return isTouchable ? super.hitTest(point, with: event) : nil
    }
    return super.hitTest(point, with: event)
}
```

**Semantic change for `touchableBounds`**

| Version | Semantics |
|---|---|
| < 3.0.0 | `touchableBounds` was a pass-through whitelist, activated only when `FlutterOverlayView` was detected (never, in Flutter 3+). Effectively a no-op. |
| 3.0.0+ | `touchableBounds` directly restricts the native ad view's touchable area. Empty = all touches reach native view (default). Non-empty = only declared rects receive touches. |

**Is click-penetration still a problem in Flutter 3+?**

For most use cases, no. TLHC mode composites Flutter content and native views through the same rendering pipeline, and the engine handles touch routing correctly. The `touchableBounds` API remains available for advanced scenarios where you need to explicitly carve out non-interactive areas on the native ad view (e.g., when a Flutter floating button overlaps the ad).

---

### Q3 — Why was `[unowned self]` replaced with `[weak self]` everywhere?

`[unowned self]` assumes the captured object is _guaranteed_ to be alive for the entire lifetime of the closure. If the object is deallocated before the closure runs, accessing `self` through an unowned reference causes a **crash** (EXC_BAD_ACCESS).

Ad SDK callbacks fire asynchronously (network responses, render callbacks). If the view controller or ad task object is released before the callback arrives — a common scenario when the user navigates away quickly — `[unowned self]` will crash.

`[weak self]` + `guard let self = self else { return }` is the correct pattern: if `self` has been deallocated the closure simply exits safely.

```swift
// Before — unsafe
closure { [unowned self] in
    self.doSomething()
}

// After — safe
closure { [weak self] in
    guard let self = self else { return }
    self.doSomething()
}
```

---

### Q4 — Why was the `NativeSplashDialog` (android.app.DialogFragment) removed?

`NativeSplashDialog` extended `android.app.DialogFragment`, which has been deprecated since API 28 and is a thin wrapper around the framework's original `DialogFragment`. It cannot be combined with AndroidX `FragmentManager`.

`SupportSplashDialog` (which extends `androidx.fragment.app.DialogFragment`) is the correct replacement and was already present in the codebase. The `NativeSplashDialog` path was dead code — it was unreachable because the surrounding logic always used the support path for projects targeting modern APIs.

---

### Q5 — Why were `systemUiVisibility` calls replaced with `WindowInsetsController`?

`View.systemUiVisibility` and related flags (`SYSTEM_UI_FLAG_*`) were **deprecated in API 30** (Android 11). On API 30+ devices the flags still work for now, but may stop working in a future Android release.

`WindowInsetsController` is the modern replacement. v3.0.0 adds an API 30+ branch while keeping the existing `systemUiVisibility` path (suppressed with `@Suppress("DEPRECATION")`) for API 24–29:

```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
    window.insetsController?.hide(WindowInsets.Type.statusBars())
} else {
    @Suppress("DEPRECATION")
    window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_FULLSCREEN
}
```

---

### Q6 — Why does the Android platform view still use `AndroidView` widget as the default?

As of Flutter 3.0, `AndroidView` internally uses **TLHC** (not the old Virtual Display mode) on API 23+ devices. The behaviour is therefore equivalent to using `PlatformViewLink` + `AndroidViewSurface` + `initSurfaceAndroidView` explicitly.

The `SurfaceAndroidBannerView` / `SurfaceAndroidFeedView` / `SurfaceAndroidSplashView` legacy classes with the `hybridComposition` toggle are kept for backward compatibility, but the `hybridComposition: true` path (`initExpensiveAndroidView` / full HC) is no longer needed for modern Flutter targets and is a candidate for deprecation in a future release.

---

## 中文

# 常见问题 & 技术决策说明

本文档解释 v3.0.0 中非显而易见的实现变更背后的原因，方便贡献者和用户理解「为什么」而不只是「改了什么」。

---

### Q1 — SplashView 为什么拆分成两个错误回调？

**v3.0.0 之前**，加载失败和渲染失败都触发同一个 `onError` 回调，Dart 层无法区分。

**v3.0.0 起**，`SplashView` 拆分为两个独立回调，与现有 `BannerView` 保持一致：

| 回调 | 触发时机 |
|---|---|
| `onError(code, message)` | 广告**加载失败**（网络错误、无填充、超时等） |
| `onRenderFail(code, message)` | 广告加载成功但**渲染失败**（模板渲染异常） |

**迁移：** 如果你之前用 `onError` 捕获所有开屏错误，只需额外添加 `onRenderFail` 处理渲染失败的情况，`onError` 语义不变。

```dart
SplashView(
  // ...
  onError: (code, msg) {
    // 加载失败 — 展示兜底界面、重试等
  },
  onRenderFail: (code, msg) {
    // 渲染失败 — 广告已拉取但无法显示
  },
)
```

---

### Q2 — iOS 端的 FlutterOverlayView 点击穿透修复去哪了？

**背景**

在早期 Flutter（Hybrid Composition 渲染模式）中，当 Flutter Widget 覆盖在原生平台 View（广告）上方时，触摸路由可能出错：Flutter 为了在原生 View 上方绘制内容而插入的 `FlutterOverlayView` 默认禁用了用户交互（`userInteractionEnabled = NO`），导致点击「穿透」到下方的原生广告，即使用户本意是点击上方的 Flutter Widget。

解决方案（见[这篇文章](http://jackin.cn/2021/02/01/bytedance-ad-click-penetration-on-flutter.html)）是重写原生 View 容器的 `hitTest`，通过类名字符串检测 `FlutterOverlayView`，如果 Overlay 覆盖了广告则返回 `nil` 拦截触摸事件。

**v3.0.0 中为什么移除了它**

Flutter 3.0 将 Android 平台 View 的默认渲染模式切换为 **TLHC（Texture Layer Hybrid Composition）**，iOS 同步优化。在 TLHC 模式下，Flutter **不再将 `FlutterOverlayView` 插入视图层级**——原生 View 的内容通过 `SurfaceTexture` 流式传入 Flutter 渲染管线。因此：

- `findTargetOverlayView` 遍历视图层级寻找类名为 `"FlutterOverlayView"` 的视图
- TLHC 模式下该视图根本不存在，函数始终返回 `nil`
- `isOverlay(targetView, nil)` 始终返回 `false`
- 整个 `hitTest` 拦截块被跳过，无条件调用 `super.hitTest`
- **在所有 Flutter 3+ 应用中这套机制是静默 no-op**

此外，通过 `String(describing: view.classForCoder) == "FlutterOverlayView"` 检测私有类名本身是脆弱的——Flutter 引擎任何版本都可能在不通知的情况下重命名该类。

**替代方案**

`hitTest` 重写简化为仅处理 `touchableBounds`：

```swift
override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard isUserInteractionEnabled, !isHidden, alpha >= 0.01 else { return nil }

    // touchableBounds 非空时，仅列表内的区域将触摸事件传递给原生 View
    // 列表外的触摸事件穿透给下方的 Flutter Widget
    if !touchableBounds.isEmpty {
        let windowPoint = self.convert(point, to: keyWindow)
        let isTouchable = touchableBounds.contains { $0.contains(windowPoint) }
        return isTouchable ? super.hitTest(point, with: event) : nil
    }
    return super.hitTest(point, with: event)
}
```

**`touchableBounds` 语义变化**

| 版本 | 语义 |
|---|---|
| < 3.0.0 | `touchableBounds` 是穿透白名单，仅在检测到 `FlutterOverlayView` 时激活（Flutter 3+ 中永远不会激活）。实际上是 no-op。 |
| 3.0.0+ | `touchableBounds` 直接限制原生广告 View 的可点击区域。列表为空 = 所有触摸传递给原生 View（默认行为）；列表非空 = 仅声明的矩形区域接收触摸。 |

**Flutter 3+ 还有点击穿透问题吗？**

绝大多数场景下没有。TLHC 模式通过统一的渲染管线合成 Flutter 内容和原生 View，引擎层面已正确处理触摸路由。`touchableBounds` API 仍然保留，用于需要精确控制原生广告 View 可交互区域的高级场景（例如 Flutter 悬浮按钮与广告 View 重叠时）。

---

### Q3 — 为什么把 `[unowned self]` 全部替换成 `[weak self]`？

`[unowned self]` 假设被捕获的对象在闭包整个生命周期内**保证存活**。如果对象在闭包执行前已被释放，通过 unowned 引用访问 `self` 会直接**崩溃**（EXC_BAD_ACCESS）。

广告 SDK 的回调是异步的（网络响应、渲染回调）。当用户快速返回上一页、视图控制器或广告 Task 对象在回调到来前已被释放时，`[unowned self]` 必然崩溃。

`[weak self]` + `guard let self = self else { return }` 是正确写法：如果 `self` 已释放，闭包安全退出。

```swift
// 修改前 — 不安全
closure { [unowned self] in
    self.doSomething()
}

// 修改后 — 安全
closure { [weak self] in
    guard let self = self else { return }
    self.doSomething()
}
```

---

### Q4 — 为什么移除了 `NativeSplashDialog`（android.app.DialogFragment）？

`NativeSplashDialog` 继承自 `android.app.DialogFragment`，该类自 API 28 起已弃用，且无法与 AndroidX `FragmentManager` 配合使用。

`SupportSplashDialog`（继承自 `androidx.fragment.app.DialogFragment`）是正确的替代，代码库中早已存在。`NativeSplashDialog` 路径是死代码——由于周围逻辑在面向现代 API 的项目中始终走 support 路径，该分支实际上从未被执行到。

---

### Q5 — 为什么用 `WindowInsetsController` 替换 `systemUiVisibility`？

`View.systemUiVisibility` 及相关 flag（`SYSTEM_UI_FLAG_*`）自 **API 30（Android 11）起已弃用**。目前在 API 30+ 设备上仍然有效，但未来 Android 版本可能停止支持。

`WindowInsetsController` 是官方替代。v3.0.0 新增 API 30+ 分支，同时保留对 API 24–29 的兼容路径：

```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
    window.insetsController?.hide(WindowInsets.Type.statusBars())
} else {
    @Suppress("DEPRECATION")
    window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_FULLSCREEN
}
```

---

### Q6 — Android 平台 View 为什么默认还是用 `AndroidView` widget？

Flutter 3.0 起，`AndroidView` 内部在 API 23+ 设备上已自动切换为 **TLHC**（不再是旧的 Virtual Display 模式）。其行为等同于显式使用 `PlatformViewLink` + `AndroidViewSurface` + `initSurfaceAndroidView`。

`SurfaceAndroidBannerView` / `SurfaceAndroidFeedView` / `SurfaceAndroidSplashView` 等 legacy 类以及 `hybridComposition` 开关保留是为了向后兼容，但 `hybridComposition: true` 路径（`initExpensiveAndroidView` / 完整 HC 模式）对现代 Flutter 目标已不再必要，计划在后续版本中标记为废弃。
