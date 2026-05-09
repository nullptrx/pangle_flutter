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
import 'ad_state.dart';

/// 激励视频广告对象。
///
/// 加载和展示分离，通过 [load] 工厂方法创建并加载，成功后调用 [show] 展示。
///
/// 示例：
/// ```dart
/// try {
///   final ad = await RewardedAd.load(
///     slotId: 'your_slot_id',
///     iOS: const IOSRewardedVideoConfig(slotId: 'xxx'),
///     android: AndroidRewardedVideoConfig(slotId: 'xxx'),
///   );
///   final result = await ad.show(
///     onEvent: (event) {
///       if (event case AdRewardEvent(:final verified) when verified) {
///         // 发放奖励
///       }
///     },
///   );
/// } on AdLoadException catch (e) {
///   debugPrint('加载失败: $e');
/// }
/// ```
class RewardedAd {
  /// 广告位 ID
  final String slotId;

  AdState _state = AdState.idle;

  /// 当前广告状态
  AdState get state => _state;

  /// 广告是否已加载完毕，可以调用 [show]
  bool get isLoaded => _state == AdState.loaded;

  RewardedAd._(this.slotId);

  /// 加载激励视频广告。
  ///
  /// 成功时返回 [RewardedAd] 实例；失败时抛出 [AdLoadException]。
  ///
  /// [slotId] 广告位 ID（iOS 和 Android 保持一致时可只传此参数）。
  /// [iOS] iOS 专属配置，slotId 将被 [slotId] 覆盖。
  /// [android] Android 专属配置，slotId 将被 [slotId] 覆盖。
  static Future<RewardedAd> load({
    required String slotId,
    IOSRewardedVideoConfig? iOS,
    AndroidRewardedVideoConfig? android,
  }) async {
    final ad = RewardedAd._(slotId);
    ad._state = AdState.loading;

    // 强制覆盖 slotId 并使用 preloadOnly，确保只加载不展示
    final iosConfig =
        (iOS ?? IOSRewardedVideoConfig(slotId: slotId)).copyWith(slotId: slotId);
    final androidConfig =
        (android ?? AndroidRewardedVideoConfig(slotId: slotId))
            .copyWith(slotId: slotId);

    final result = await pangle.loadRewardedVideoAdOnly(
      iOS: iosConfig,
      android: androidConfig,
    );

    if (result.ok) {
      ad._state = AdState.loaded;
      return ad;
    } else {
      ad._state = AdState.failed;
      throw AdLoadException(code: result.code ?? -1, message: result.message);
    }
  }

  /// 展示已加载的激励视频广告。
  ///
  /// 必须在 [isLoaded] 为 true 时调用，否则抛出 [StateError]。
  ///
  /// [onEvent] 广告生命周期事件回调，使用类型安全的 [PangleAdEvent]。
  ///
  /// 返回 [PangleVerifyResult]，其中 [PangleVerifyResult.isVerify] 表示
  /// 服务端奖励验证是否通过。
  Future<PangleVerifyResult> show({
    void Function(PangleAdEvent event)? onEvent,
  }) async {
    if (_state != AdState.loaded) {
      throw StateError(
        'RewardedAd[$slotId] 无法展示：当前状态为 $_state，请先调用 load()。',
      );
    }
    _state = AdState.showing;

    final result = await pangle.showRewardedVideoAd(
      slotId: slotId,
      callback: onEvent == null
          ? null
          : (raw) => onEvent(
                PangleAdEvent.fromRaw(raw, isRewarded: true),
              ),
    );

    _state = AdState.disposed;
    return result;
  }
}
