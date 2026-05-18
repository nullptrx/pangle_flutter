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

/// 全屏视频广告对象（新模板渲染插屏）。
///
/// 加载和展示分离，通过 [load] 工厂方法创建并加载，成功后调用 [show] 展示。
///
/// 示例：
/// ```dart
/// try {
///   final ad = await FullscreenAd.load(
///     slotId: 'your_slot_id',
///     iOS: const IOSFullscreenVideoConfig(slotId: 'xxx'),
///     android: AndroidFullscreenVideoConfig(slotId: 'xxx'),
///   );
///   await ad.show(
///     onEvent: (event) {
///       if (event is AdClosedEvent) Navigator.pop(context);
///     },
///   );
/// } on AdLoadException catch (e) {
///   debugPrint('加载失败: $e');
/// }
/// ```
class FullscreenAd {
  /// 广告位 ID
  final String slotId;

  AdState _state = AdState.idle;

  /// 当前广告状态
  AdState get state => _state;

  /// 广告是否已加载完毕，可以调用 [show]
  bool get isLoaded => _state == AdState.loaded;

  FullscreenAd._(this.slotId);

  /// 加载全屏视频广告。
  ///
  /// 成功时返回 [FullscreenAd] 实例；失败时抛出 [AdLoadException]。
  ///
  /// [slotId] 广告位 ID（iOS 和 Android 保持一致时可只传此参数）。
  /// [iOS] iOS 专属配置，slotId 将被 [slotId] 覆盖。
  /// [android] Android 专属配置，slotId 将被 [slotId] 覆盖。
  static Future<FullscreenAd> load({
    required String slotId,
    IOSFullscreenVideoConfig? iOS,
    AndroidFullscreenVideoConfig? android,
  }) async {
    final ad = FullscreenAd._(slotId);
    ad._state = AdState.loading;

    final iosConfig =
        (iOS ?? IOSFullscreenVideoConfig(slotId: slotId)).copyWith(slotId: slotId);
    final androidConfig =
        (android ?? AndroidFullscreenVideoConfig(slotId: slotId))
            .copyWith(slotId: slotId);

    final result = await pangle.loadFullscreenVideoAdOnly(
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

  /// 展示已加载的全屏视频广告。
  ///
  /// 必须在 [isLoaded] 为 true 时调用，否则抛出 [StateError]。
  ///
  /// [onEvent] 广告生命周期事件回调，使用类型安全的 [PangleAdEvent]。
  ///
  /// 返回 [PangleResult]，[PangleResult.ok] 为 true 表示正常关闭。
  Future<PangleResult> show({
    void Function(PangleAdEvent event)? onEvent,
  }) async {
    if (_state != AdState.loaded) {
      throw StateError(
        'FullscreenAd[$slotId] 无法展示：当前状态为 $_state，请先调用 load()。',
      );
    }
    _state = AdState.showing;

    final result = await pangle.showFullscreenVideoAd(
      slotId: slotId,
      callback: onEvent == null
          ? null
          : (raw) => onEvent(PangleAdEvent.fromRaw(raw)),
    );

    _state = AdState.disposed;
    return result;
  }
}
