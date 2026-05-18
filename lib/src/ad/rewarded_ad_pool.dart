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

import '../config_android.dart';
import '../config_ios.dart';
import '../model.dart';
import '../pangle_plugin.dart';
import 'ad_event.dart';

/// 激励视频广告预加载池配置
class _RewardedSlotConfig {
  final IOSRewardedVideoConfig? iOS;
  final AndroidRewardedVideoConfig? android;

  /// 同时维持的预加载数量
  final int poolSize;

  /// 广告展示后是否自动触发新一轮预加载
  final bool autoRefill;

  /// 当前正在进行中的加载任务数
  int _loading = 0;

  _RewardedSlotConfig({
    required this.iOS,
    required this.android,
    required this.poolSize,
    required this.autoRefill,
  });
}

/// 激励视频广告预加载池。
///
/// 单例，统一管理多个广告位的预加载、缓存查询和展示。
/// 展示后会自动从 native 缓存中取广告，并根据配置触发补充加载。
///
/// 典型用法：
/// ```dart
/// // 1. 应用启动时配置并开始预加载
/// await RewardedAdPool.instance.configure(
///   slotId: 'your_slot_id',
///   poolSize: 2,
///   android: AndroidRewardedVideoConfig(slotId: 'your_slot_id'),
///   iOS: const IOSRewardedVideoConfig(slotId: 'your_slot_id'),
/// );
///
/// // 2. 展示时调用（内部自动从 native 缓存取，展示后按需补充）
/// if (await RewardedAdPool.instance.isReady('your_slot_id')) {
///   final result = await RewardedAdPool.instance.show(
///     slotId: 'your_slot_id',
///     onEvent: (event) {
///       if (event case AdRewardEvent(:final verified) when verified) {
///         // 发放奖励
///       }
///     },
///   );
/// }
/// ```
class RewardedAdPool {
  RewardedAdPool._();

  static final RewardedAdPool instance = RewardedAdPool._();

  final Map<String, _RewardedSlotConfig> _configs = {};

  /// 配置并开始对指定广告位进行预加载。
  ///
  /// 可重复调用以更新配置，会立即触发一次预加载补充。
  ///
  /// [slotId] 广告位 ID
  /// [poolSize] 同时维持的 native 缓存数量，默认 1
  /// [autoRefill] 展示后是否自动补充，默认 true
  /// [iOS] iOS 广告配置
  /// [android] Android 广告配置
  Future<void> configure({
    required String slotId,
    int poolSize = 1,
    bool autoRefill = true,
    IOSRewardedVideoConfig? iOS,
    AndroidRewardedVideoConfig? android,
  }) async {
    _configs[slotId] = _RewardedSlotConfig(
      iOS: iOS,
      android: android,
      poolSize: poolSize,
      autoRefill: autoRefill,
    );
    await _refill(slotId);
  }

  /// 查询 native 缓存中是否有未过期的可用广告。
  Future<bool> isReady(String slotId) {
    return pangle.hasRewardedVideoAd(slotId);
  }

  /// 展示广告。
  ///
  /// 内部直接调用 native 的 show 方法，从缓存取广告展示。
  /// 展示后如果 [autoRefill] 为 true，会自动触发补充加载。
  ///
  /// 如果 native 缓存为空（广告还没加载好），返回 null。
  ///
  /// [onEvent] 生命周期事件回调
  Future<PangleVerifyResult?> show({
    required String slotId,
    void Function(PangleAdEvent event)? onEvent,
  }) async {
    final config = _configs[slotId];

    final result = await pangle.showRewardedVideoAd(
      slotId: slotId,
      callback: onEvent == null
          ? null
          : (raw) => onEvent(PangleAdEvent.fromRaw(raw, isRewarded: true)),
    );

    // code != 0 通常意味着 native 缓存为空（广告未就绪）
    if (!result.ok) return null;

    // 展示成功后自动补充
    if (config != null && config.autoRefill) {
      _refill(slotId);
    }

    return result;
  }

  /// 手动触发指定广告位的预加载补充。
  Future<void> preload(String slotId) => _refill(slotId);

  /// 移除某广告位的配置，停止自动补充。
  void dispose(String slotId) {
    _configs.remove(slotId);
  }

  // ──────────────────────────────────────
  // 内部方法
  // ──────────────────────────────────────

  Future<void> _refill(String slotId) async {
    final config = _configs[slotId];
    if (config == null) return;

    // 查询 native 当前缓存数 + 正在加载数，决定需要补充几个
    final hasAd = await pangle.hasRewardedVideoAd(slotId);
    final cachedCount = hasAd ? 1 : 0; // native 只告诉我们有没有，不告诉数量
    final needed = config.poolSize - cachedCount - config._loading;
    if (needed <= 0) return;

    for (var i = 0; i < needed; i++) {
      _loadOne(slotId, config);
    }
  }

  void _loadOne(String slotId, _RewardedSlotConfig config) {
    config._loading++;

    pangle
        .loadRewardedVideoAdOnly(
          iOS: config.iOS?.copyWith(slotId: slotId) ??
              IOSRewardedVideoConfig(slotId: slotId),
          android: config.android?.copyWith(slotId: slotId) ??
              AndroidRewardedVideoConfig(slotId: slotId),
        )
        .then((_) => config._loading--)
        .catchError((_) => config._loading--);
  }
}
