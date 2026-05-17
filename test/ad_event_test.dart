import 'package:flutter_test/flutter_test.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

void main() {
  group('PangleAdEvent.fromRaw', () {
    test('load → AdLoadedEvent', () {
      expect(PangleAdEvent.fromRaw('load'), isA<AdLoadedEvent>());
    });

    test('cached → AdCachedEvent', () {
      expect(PangleAdEvent.fromRaw('cached'), isA<AdCachedEvent>());
    });

    test('show → AdShownEvent', () {
      expect(PangleAdEvent.fromRaw('show'), isA<AdShownEvent>());
    });

    test('skip → AdSkippedEvent', () {
      expect(PangleAdEvent.fromRaw('skip'), isA<AdSkippedEvent>());
    });

    test('click → AdClickedEvent', () {
      expect(PangleAdEvent.fromRaw('click'), isA<AdClickedEvent>());
    });

    test('complete → AdCompletedEvent', () {
      expect(PangleAdEvent.fromRaw('complete'), isA<AdCompletedEvent>());
    });

    test('close → AdClosedEvent', () {
      expect(PangleAdEvent.fromRaw('close'), isA<AdClosedEvent>());
    });

    test('error → AdErrorEvent', () {
      expect(PangleAdEvent.fromRaw('error'), isA<AdErrorEvent>());
    });

    test('render_fail → AdRenderFailedEvent', () {
      expect(PangleAdEvent.fromRaw('render_fail'), isA<AdRenderFailedEvent>());
    });

    test('render_success → AdRenderSuccessEvent', () {
      expect(
        PangleAdEvent.fromRaw('render_success'),
        isA<AdRenderSuccessEvent>(),
      );
    });

    test('unknown string → AdUnknownEvent preserving raw value', () {
      final event = PangleAdEvent.fromRaw('some_future_event');
      expect(event, isA<AdUnknownEvent>());
      expect((event as AdUnknownEvent).raw, 'some_future_event');
    });
  });

  group('AdRewardEvent — isRewarded=true', () {
    test('reward_verify_success → verified=true', () {
      final event = PangleAdEvent.fromRaw(
        'reward_verify_success',
        isRewarded: true,
      );
      expect(event, isA<AdRewardEvent>());
      expect((event as AdRewardEvent).verified, true);
    });

    test('reward_verify_failure → verified=false', () {
      final event = PangleAdEvent.fromRaw(
        'reward_verify_failure',
        isRewarded: true,
      );
      expect(event, isA<AdRewardEvent>());
      expect((event as AdRewardEvent).verified, false);
    });

    test('reward_verify_* without isRewarded flag → AdUnknownEvent', () {
      final event = PangleAdEvent.fromRaw('reward_verify_success');
      expect(event, isA<AdUnknownEvent>());
    });
  });

  group('sealed class exhaustiveness', () {
    test('all subtypes are distinct', () {
      final events = [
        const AdLoadedEvent(),
        const AdCachedEvent(),
        const AdShownEvent(),
        const AdSkippedEvent(),
        const AdClickedEvent(),
        const AdCompletedEvent(),
        const AdClosedEvent(),
        const AdErrorEvent(),
        const AdRenderFailedEvent(),
        const AdRenderSuccessEvent(),
        const AdRewardEvent(verified: true),
        const AdUnknownEvent('x'),
      ];
      final types = events.map((e) => e.runtimeType).toSet();
      expect(types.length, events.length);
    });

    test('switch on sealed class compiles and dispatches correctly', () {
      int closedCount = 0;
      int rewardCount = 0;

      void handle(PangleAdEvent event) {
        switch (event) {
          case AdClosedEvent():
            closedCount++;
          case AdRewardEvent(:final verified) when verified:
            rewardCount++;
          default:
            break;
        }
      }

      handle(const AdClosedEvent());
      handle(const AdRewardEvent(verified: true));
      handle(const AdRewardEvent(verified: false));
      handle(const AdShownEvent());

      expect(closedCount, 1);
      expect(rewardCount, 1);
    });
  });
}
