---
name: pangle_flutter 开发进度
description: 各模块当前完成状态，agent 继续开发时先读这里确认起点
type: project
originSessionId: 11d20578-102e-4724-a014-b46b77d8be86
---
## 当前状态（2026-05-17）

所有代码工作在 worktree `frosty-cori-2c16ab`，分支 `claude/frosty-cori-2c16ab`。

---

## Phase 1：Flutter Example

| 模块 | 状态 | 说明 |
|------|------|------|
| `constant.dart` 更新 | ⬜ 未开始 | 补充所有 Android/iOS 广告位 ID |
| 首页重构（8入口） | ⬜ 未开始 | 对齐 MainActivity |
| 开屏广告页（9种变体） | ⬜ 未开始 | SplashListPage |
| 激励视频页（横/竖 + 加载/展示分离） | ⬜ 未开始 | RewardListPage + RewardPage |
| 全屏视频+新插屏页（4种） | ⬜ 未开始 | FullscreenListPage |
| Banner 页（原生+模板多尺寸） | ⬜ 未开始 | BannerListPage |
| 信息流页（列表+图标+Mall） | ⬜ 未开始 | FeedListPage |
| Draw 竖版视频页 | ⬜ 未开始 | DrawListPage + DrawPage |
| Stream 自定义播放器页 | ⬜ 未开始 | StreamPage |
| 瀑布流页 | ⬜ 未开始 | WaterfallPage |

## Phase 2：Flutter Plugin Dart 层

| 模块 | 状态 | 说明 |
|------|------|------|
| `AndroidSplashConfig` 参数完整化 | ⬜ 未开始 | isHalfSize/timeout/expressSize 等 |
| `IOSSplashConfig` 参数完整化 | ⬜ 未开始 | tolerateTimeout/hideSkipButton 等 |
| `AndroidRewardedVideoConfig` 完整化 | ⬜ 未开始 | adLoadType/rewardAmount/rewardName |
| `IOSRewardedVideoConfig` 完整化 | ⬜ 未开始 | rewardName/rewardAmount |
| `AndroidFullscreenVideoConfig` 完整化 | ⬜ 未开始 | adLoadType |
| `IOSFullscreenVideoConfig` 完整化 | ⬜ 未开始 | isInterstitialAd |
| `AndroidBannerConfig` 完整化 | ⬜ 未开始 | expressViewWidth/Height |
| `IOSBannerConfig` 完整化 | ⬜ 未开始 | adWidth/adHeight/interval |
| `AndroidNativeBannerConfig` 新增 | ⬜ 未开始 | supportRenderControl/imageSize |
| `AndroidFeedConfig` 完整化 | ⬜ 未开始 | adCount/expressViewWidth/Height |
| `IOSFeedConfig` 完整化 | ⬜ 未开始 | supportRenderControl/adWidth/adHeight |
| `AndroidFeedIconConfig` 新增 | ⬜ 未开始 | supportIconStyle + 独立方法 |
| `AndroidDrawConfig` / `IOSDrawConfig` 新增 | ⬜ 未开始 | Draw 广告配置类 |
| `AndroidStreamConfig` / `IOSStreamConfig` 新增 | ⬜ 未开始 | Stream 广告配置类 |
| `PangleDrawAd` / `PangleStreamAd` 模型 | ⬜ 未开始 | model.dart |
| `loadFeedIconAd()` 方法 | ⬜ 未开始 | pangle_plugin.dart |
| `loadDrawAd()` / `removeDrawAd()` | ⬜ 未开始 | pangle_plugin.dart |
| `loadStreamAd()` | ⬜ 未开始 | pangle_plugin.dart |
| `DrawView` Widget | ⬜ 未开始 | lib/src/view/drawview.dart |
| 旧无用代码清理 | ⬜ 未开始 | 删除 demo 中未使用的参数/类 |

## Phase 3：Android Plugin

| 模块 | 状态 | 说明 |
|------|------|------|
| Splash isHalfSize 支持 | ⬜ 未开始 | FLTSplashAd.kt |
| Reward adLoadType/rewardAmount/rewardName | ⬜ 未开始 | FLTRewardedVideoAd.kt |
| Fullscreen adLoadType | ⬜ 未开始 | FLTFullScreenVideoAd.kt |
| Banner expressViewWidth/Height | ⬜ 未开始 | FLTBannerExpressAd.kt |
| NativeBanner 实现 | ⬜ 未开始 | FLTNativeBannerAd.kt（新增） |
| Feed adCount/expressViewWidth/Height | ⬜ 未开始 | FLTNativeExpressAd.kt |
| FeedIcon supportIconStyle | ⬜ 未开始 | FLTNativeExpressAd.kt |
| Draw loadExpressDrawFeedAd | ⬜ 未开始 | FLTDrawAd.kt（新增） |
| Stream loadStream | ⬜ 未开始 | FLTStreamAd.kt（新增） |

## Phase 4：iOS Plugin

| 模块 | 状态 | 说明 |
|------|------|------|
| Splash tolerateTimeout/hideSkipButton/adSize | ⬜ 未开始 | FLTSplashView.swift |
| Reward rewardName/rewardAmount | ⬜ 未开始 | PangleAdManager.swift |
| Fullscreen isInterstitialAd | ⬜ 未开始 | PangleAdManager.swift |
| Banner adWidth/adHeight/interval | ⬜ 未开始 | FLTBannerView.swift |
| Feed BUAdSlot 完整参数 | ⬜ 未开始 | FLTFeedView.swift |
| Draw BUAdSlotAdTypeDrawVideo | ⬜ 未开始 | FLTDrawView.swift（新增） |
| Stream BUNativeAdsManager | ⬜ 未开始 | PangleAdManager.swift |

---

## 状态说明
- ⬜ 未开始
- 🔄 进行中
- ✅ 已完成（已 commit）
