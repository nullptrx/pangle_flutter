// Copyright (c) 2021 nullptrX
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/// 广告生命周期事件，由 native EventChannel 推送。
///
/// 使用 sealed class + switch 可获得编译期穷举检查：
/// ```dart
/// switch (event) {
///   case AdRewardEvent(:final verified):
///     if (verified) grantReward();
///   case AdClosedEvent():
///     Navigator.pop(context);
///   default:
///     break;
/// }
/// ```
sealed class PangleAdEvent {
  const PangleAdEvent();

  /// 将 native 推送的原始字符串转换为对应事件对象。
  ///
  /// [raw] native 推送的字符串，如 "load"、"cached" 等。
  /// [isRewarded] 是否是激励视频广告（用于区分 reward_verify_* 事件）。
  factory PangleAdEvent.fromRaw(String raw, {bool isRewarded = false}) {
    if (isRewarded && raw.startsWith('reward_verify_')) {
      return AdRewardEvent(verified: raw == 'reward_verify_success');
    }
    return switch (raw) {
      'load' => const AdLoadedEvent(),
      'cached' => const AdCachedEvent(),
      'show' => const AdShownEvent(),
      'skip' => const AdSkippedEvent(),
      'click' => const AdClickedEvent(),
      'complete' => const AdCompletedEvent(),
      'close' => const AdClosedEvent(),
      'error' => const AdErrorEvent(),
      'render_fail' => const AdRenderFailedEvent(),
      'render_success' => const AdRenderSuccessEvent(),
      _ => AdUnknownEvent(raw),
    };
  }
}

// ──────────────────────────────────────────────
// 加载阶段
// ──────────────────────────────────────────────

/// 广告请求成功，对象已进入 native 缓存队列。
///
/// 注意：此时视频素材可能还在下载，[AdCachedEvent] 才代表可以无卡顿播放。
final class AdLoadedEvent extends PangleAdEvent {
  const AdLoadedEvent();
}

/// 视频素材已完整下载到本地，展示时不会有加载卡顿。
final class AdCachedEvent extends PangleAdEvent {
  const AdCachedEvent();
}

// ──────────────────────────────────────────────
// 展示阶段
// ──────────────────────────────────────────────

/// 广告已出现在屏幕上。
final class AdShownEvent extends PangleAdEvent {
  const AdShownEvent();
}

/// 用户点击了跳过按钮。
final class AdSkippedEvent extends PangleAdEvent {
  const AdSkippedEvent();
}

/// 用户点击了广告内容。
final class AdClickedEvent extends PangleAdEvent {
  const AdClickedEvent();
}

/// 视频播放完毕。
final class AdCompletedEvent extends PangleAdEvent {
  const AdCompletedEvent();
}

/// 广告已关闭（用户退出）。
final class AdClosedEvent extends PangleAdEvent {
  const AdClosedEvent();
}

// ──────────────────────────────────────────────
// 渲染
// ──────────────────────────────────────────────

/// 广告渲染成功（iOS 特有）。
final class AdRenderSuccessEvent extends PangleAdEvent {
  const AdRenderSuccessEvent();
}

/// 广告渲染失败，通常意味着素材损坏，Pool 可据此触发重新加载。
final class AdRenderFailedEvent extends PangleAdEvent {
  const AdRenderFailedEvent();
}

// ──────────────────────────────────────────────
// 失败
// ──────────────────────────────────────────────

/// 加载或展示出错。
final class AdErrorEvent extends PangleAdEvent {
  const AdErrorEvent();
}

// ──────────────────────────────────────────────
// 激励视频专用
// ──────────────────────────────────────────────

/// 服务端奖励验证结果（仅激励视频）。
final class AdRewardEvent extends PangleAdEvent {
  /// true 表示服务端验证通过，可以发放奖励。
  final bool verified;

  const AdRewardEvent({required this.verified});
}

// ──────────────────────────────────────────────
// 兜底
// ──────────────────────────────────────────────

/// 未知事件，[raw] 为 native 推送的原始字符串。
final class AdUnknownEvent extends PangleAdEvent {
  final String raw;

  const AdUnknownEvent(this.raw);
}
