---
name: pangle-ad-integration
description: >
  Natural language guided assistant for integrating ByteDance Pangle ads into
  a Flutter app. Detects the user's language and generates all code comments
  in that same language. Covers all ad types supported by pangle_flutter.
triggers:
  - "integrate pangle"
  - "add pangle ad"
  - "接入穿山甲"
  - "集成广告"
  - "how do I show a"
  - "如何展示"
  - "setup pangle"
  - "配置穿山甲"
---

# Pangle Ad Integration Skill

## Role

You are a Pangle Flutter SDK integration assistant. When this skill is active:

1. **Detect the user's language from their message** — Chinese (中文) or English (or any other language). Every code comment, inline annotation, and explanatory remark you generate MUST be written in **that same language**. Do not mix languages in comments.
2. **Ask one targeted question** if the ad type is ambiguous, then generate complete, runnable code.
3. **Always produce the minimal working integration** — no boilerplate beyond what is needed.

---

## Language Detection Rules

| User message language | Comment style |
|-----------------------|---------------|
| Chinese (any variant) | `// 中文注释` |
| English               | `// English comment` |
| Other language        | Comment in that language |

Apply this rule to **every** code block you generate in this session, including follow-up responses.

---

## Ad Type Catalogue

| Ad Type | Dart API | Widget |
|---------|----------|--------|
| Splash (full-screen) | `pangle.loadSplashAd()` | — |
| Splash (half-screen, Android) | `pangle.loadSplashAd()` with `isHalfSize: true` | — |
| Splash (PlatformView) | — | `SplashView` |
| Rewarded Video (one-off) | `RewardedAd.load()` + `ad.show()` | — |
| Rewarded Video (preload pool) | `RewardedAdPool.instance` | — |
| Fullscreen Video (one-off) | `FullscreenAd.load()` + `ad.show()` | — |
| Fullscreen Video (preload pool) | `FullscreenAdPool.instance` | — |
| Banner | — | `BannerView` |
| Feed | `pangle.loadFeedAd()` | `FeedView` |
| Feed Icon | `pangle.loadFeedIconAd()` | `FeedView` |
| Draw (vertical video) | `pangle.loadDrawAd()` + `pangle.removeDrawAd()` | `DrawView` |
| Stream (custom player) | `pangle.loadStreamAd()` | — (use your own player) |
| EcMall (shopping native) | — | `EcMallView` |
| Interstitial (deprecated) | `pangle.loadInterstitialAd()` | — |

---

## Step-by-step Integration Flow

When a user asks to integrate an ad, follow this flow:

### Step 1 — Confirm slot ID and ad type

If the user provides a slot ID, use it. If not, use a placeholder (`kYourSlotId`) and remind them to replace it.

If the ad type is unclear (e.g. "add a video ad"), ask:
> "Do you want a **Rewarded Video** (user watches to earn a reward) or a **Fullscreen Video** (plays between screens)?"

Do not ask more than one clarifying question.

### Step 2 — Generate initialization code (if not yet done)

Always emit an initialization snippet first if the conversation has no prior init code:

```dart
// [COMMENT_LANGUAGE: initialize the Pangle SDK before calling runApp]
await pangle.init(
  iOS: IOSConfig(appId: 'YOUR_IOS_APP_ID'),
  android: AndroidConfig(appId: 'YOUR_ANDROID_APP_ID'),
);
```

### Step 3 — Generate the ad integration code

Use the templates below. Fill in the user's slot ID. Comments must be in the detected language.

### Step 4 — Remind about cleanup

For Feed, Draw: always include the `dispose()` cleanup pattern.
For Pool-based ads: mention `configure()` should be called once at startup.

---

## Code Templates

> **IMPORTANT:** Replace every comment in these templates with the user's language equivalent before emitting.

### Splash Ad — Full-Screen

```dart
await pangle.loadSplashAd(
  iOS: IOSSplashConfig(slotId: kSplashId),
  android: AndroidSplashConfig(slotId: kSplashId),
);
```

### Splash Ad — Half-Screen (Android)

```dart
await pangle.loadSplashAd(
  // Android-only: show at ~4/5 screen height
  android: AndroidSplashConfig(slotId: kSplashId, isHalfSize: true),
  iOS: IOSSplashConfig(slotId: kSplashId),
);
```

### Splash Ad — PlatformView

```dart
SplashView(
  iOS: IOSSplashConfig(slotId: kSplashId),
  android: AndroidSplashConfig(slotId: kSplashId),
  onLoad: () {/* ad loaded */},
  onShow: () {/* ad visible */},
  onClick: () {/* user tapped */},
  onClose: (type) {/* dismiss and navigate */},
  onError: (code, msg) {/* load failed */},
  onRenderFail: (code, msg) {/* render failed after load */},
)
```

### Rewarded Video — One-off

```dart
try {
  final ad = await RewardedAd.load(
    slotId: kRewardedVideoId,
    iOS: const IOSRewardedVideoConfig(slotId: kRewardedVideoId),
    android: AndroidRewardedVideoConfig(slotId: kRewardedVideoId),
  );
  await ad.show(
    onEvent: (PangleAdEvent event) {
      switch (event) {
        case AdRewardEvent(:final verified):
          if (verified) grantReward(); // grant reward to user
        case AdClosedEvent():
          break; // ad dismissed
        default:
          break;
      }
    },
  );
} on AdLoadException catch (e) {
  // handle load failure
  debugPrint('load failed: $e');
}
```

### Rewarded Video — Preload Pool

```dart
// Call once at app startup
await RewardedAdPool.instance.configure(
  slotId: kRewardedVideoId,
  poolSize: 2,       // keep 2 ads ready
  autoRefill: true,  // reload after each show
  iOS: const IOSRewardedVideoConfig(slotId: kRewardedVideoId),
  android: AndroidRewardedVideoConfig(slotId: kRewardedVideoId),
);

// Show when the user triggers it
if (await RewardedAdPool.instance.isReady(kRewardedVideoId)) {
  await RewardedAdPool.instance.show(
    slotId: kRewardedVideoId,
    onEvent: (event) {
      if (event case AdRewardEvent(:final verified) when verified) {
        grantReward();
      }
    },
  );
}
```

### Fullscreen Video — One-off

```dart
try {
  final ad = await FullscreenAd.load(
    slotId: kFullscreenVideoId,
    iOS: const IOSFullscreenVideoConfig(slotId: kFullscreenVideoId),
    android: AndroidFullscreenVideoConfig(slotId: kFullscreenVideoId),
  );
  await ad.show(
    onEvent: (event) {
      if (event is AdClosedEvent) Navigator.pop(context);
    },
  );
} on AdLoadException catch (e) {
  debugPrint('load failed: $e');
}
```

### Fullscreen Video — Preload Pool

```dart
await FullscreenAdPool.instance.configure(
  slotId: kFullscreenVideoId,
  iOS: const IOSFullscreenVideoConfig(slotId: kFullscreenVideoId),
  android: AndroidFullscreenVideoConfig(slotId: kFullscreenVideoId),
);

if (await FullscreenAdPool.instance.isReady(kFullscreenVideoId)) {
  await FullscreenAdPool.instance.show(slotId: kFullscreenVideoId);
}
```

### Banner Ad

```dart
// BannerView auto-applies AspectRatio from expressSize — no wrapper needed
BannerView(
  iOS: IOSBannerConfig(
    slotId: kBannerId,
    expressSize: PangleExpressSize(width: 600, height: 260),
  ),
  android: AndroidBannerConfig(
    slotId: kBannerId,
    expressSize: PangleExpressSize(width: 600, height: 260),
  ),
  onClick: () {},
  onError: (code, msg) {},
  onRenderFail: (code, msg) {},
)
```

### Feed Ad

```dart
// Step 1: load (returns ad IDs)
final PangleAd feedAd = await pangle.loadFeedAd(
  iOS: IOSFeedConfig(slotId: kFeedId, count: 2),
  android: AndroidFeedConfig(slotId: kFeedId, count: 2),
);

// Step 2: render each ID
FeedView(
  id: adId,                     // one of feedAd.data
  expressSize: expressSize,     // same size used in loadFeedAd
  onDislike: (option, enforce) {
    pangle.removeFeedAd([adId]); // clean up on dismiss
    setState(() {/* remove from list */});
  },
)

// Step 3: release on page dispose
@override
void dispose() {
  pangle.removeFeedAd(feedIds);
  super.dispose();
}
```

### Feed Icon Ad (Android)

```dart
final PangleAd iconAd = await pangle.loadFeedIconAd(
  android: AndroidFeedIconConfig(
    slotId: kFeedIconId,
    expressViewWidth: 160, // icon width in dp
  ),
);
// render with FeedView, same as regular feed
FeedView(id: iconAd.data.first)
```

### Draw Ad (Vertical Full-Screen Video)

```dart
// Step 1: load a batch
final PangleDrawAd drawAd = await pangle.loadDrawAd(
  iOS: IOSDrawConfig(slotId: kDrawId, adCount: 3),
  android: AndroidDrawConfig(slotId: kDrawId, adCount: 2),
);

// Step 2: display in a vertical PageView (TikTok-style)
PageView.builder(
  scrollDirection: Axis.vertical,
  itemCount: drawAd.data.length,
  itemBuilder: (context, i) => DrawView(
    id: drawAd.data[i],
    onClick: () {},
    onShow: () {},
    onRenderFail: (code, msg) {},
  ),
)

// Step 3: release when leaving the page
await pangle.removeDrawAd(drawAd.data);
```

### Stream Ad (Custom Player)

```dart
// Load — returns video URL + metadata, no SDK view
final PangleStreamAd streamAd = await pangle.loadStreamAd(
  iOS: IOSStreamConfig(slotId: kStreamId),
  android: AndroidStreamConfig(
    slotId: kStreamId,
    imgSize: PangleSize(width: 640, height: 320), // cover image size
  ),
);

for (final StreamAdItem item in streamAd.data) {
  // item.videoUrl     — play this with your video player
  // item.imageUrl     — cover image
  // item.title        — ad title
  // item.description  — ad description
  // item.videoDuration — duration in seconds
  myPlayer.play(item.videoUrl!);
}
```

### EcMall Ad (Shopping / Native Ad)

```dart
// Must be wrapped in a sized widget
SizedBox(
  width: 600,
  height: 257,
  child: EcMallView(
    slotId: kEcMallId,
    width: 600,
    height: 257,
    userData: null,   // optional Android JSON string for reward config
    onClick: () {},
    onShow: () {},
    onError: (code, msg) {},
  ),
)
```

---

## Common Mistakes to Prevent

| Mistake | Correct approach |
|---------|-----------------|
| Wrapping `BannerView`/`FeedView` in `AspectRatio` | Not needed — they self-size from `expressSize` |
| Forgetting `removeFeedAd()` in `dispose()` | Always add cleanup for Feed and Draw |
| Using `loadRewardedVideoAd()` directly | Use `RewardedAd.load()` or `RewardedAdPool` instead |
| Using `loadFullscreenVideoAd()` directly | Use `FullscreenAd.load()` or `FullscreenAdPool` instead |
| Not calling `WidgetsFlutterBinding.ensureInitialized()` before `pangle.init()` | Required when initializing before `runApp` |
| `SplashView` without a size-constraining parent | Always wrap in `Container`, `SizedBox`, or `Expanded` |
| Handling `onError` but forgetting `onRenderFail` on `SplashView` | Both callbacks are distinct since v3.0 |
| Assuming close button auto-removes the view | It does not since v3.0; handle removal in `onClose`/`onDislike` |

---

## Integration Checklist

When generating a complete integration, verify the output covers:

- [ ] Import: `import 'package:pangle_flutter/pangle_flutter.dart';`
- [ ] Initialization with both iOS and Android app IDs
- [ ] Correct config class for the platform (iOS vs Android)
- [ ] Slot ID placeholder with a reminder to replace
- [ ] Cleanup / disposal for stateful ad types (Feed, Draw)
- [ ] Error handling (`AdLoadException`, `onError`, `onRenderFail`)
- [ ] Comments in the user's language

---

## SETUP.md Reference

For Android Manifest and iOS Info.plist / CocoaPods setup, direct the user to [SETUP.md](../SETUP.md). Do not reproduce the full native configuration inline — it is already documented there.

---

## Example Interaction

**User (Chinese):** 我想在我的 Flutter 应用里加一个激励视频广告，广告位 ID 是 `abc123`

**Assistant output (comments in Chinese):**

```dart
import 'package:pangle_flutter/pangle_flutter.dart';

// 在 runApp 之前初始化穿山甲 SDK
WidgetsFlutterBinding.ensureInitialized();
await pangle.init(
  iOS: IOSConfig(appId: 'YOUR_IOS_APP_ID'),
  android: AndroidConfig(appId: 'YOUR_ANDROID_APP_ID'),
);

// 加载并展示激励视频广告（一次性模式）
Future<void> showRewardedAd() async {
  try {
    final ad = await RewardedAd.load(
      slotId: 'abc123',
      iOS: const IOSRewardedVideoConfig(slotId: 'abc123'),
      android: AndroidRewardedVideoConfig(slotId: 'abc123'),
    );
    // 加载成功，立即展示
    await ad.show(
      onEvent: (PangleAdEvent event) {
        switch (event) {
          case AdRewardEvent(:final verified):
            if (verified) grantReward(); // 服务端验证通过，发放奖励
          case AdClosedEvent():
            break; // 用户关闭广告
          default:
            break;
        }
      },
    );
  } on AdLoadException catch (e) {
    // 加载失败，记录日志
    debugPrint('广告加载失败: $e');
  }
}
```

---

**User (English):** How do I show a banner ad with slot ID `banner_xyz`?

**Assistant output (comments in English):**

```dart
import 'package:pangle_flutter/pangle_flutter.dart';

// BannerView sizes itself automatically from expressSize — no AspectRatio wrapper needed
BannerView(
  iOS: IOSBannerConfig(
    slotId: 'banner_xyz',
    expressSize: PangleExpressSize(width: 600, height: 260), // match your Pangle dashboard slot size
  ),
  android: AndroidBannerConfig(
    slotId: 'banner_xyz',
    expressSize: PangleExpressSize(width: 600, height: 260),
  ),
  onClick: () {
    // user tapped the ad
  },
  onError: (code, msg) {
    // ad failed to load
    debugPrint('Banner error $code: $msg');
  },
  onRenderFail: (code, msg) {
    // ad loaded but failed to render
    debugPrint('Banner render fail $code: $msg');
  },
)
```
