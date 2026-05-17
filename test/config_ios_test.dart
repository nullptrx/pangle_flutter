import 'package:flutter_test/flutter_test.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IOSConfig', () {
    test('required field only', () {
      const config = IOSConfig(appId: 'ios_app');
      final json = config.toJSON();
      expect(json['appId'], 'ios_app');
      expect(json['logLevel'], isNull);
      expect(json['idfa'], isNull);
    });

    test('logLevel serializes as index', () {
      const config = IOSConfig(
        appId: 'ios_app',
        logLevel: PangleLogLevel.debug,
      );
      expect(config.toJSON()['logLevel'], PangleLogLevel.debug.index);
    });
  });

  group('IOSSplashConfig', () {
    test('required field only', () {
      const config = IOSSplashConfig(slotId: 'splash1');
      final json = config.toJSON();
      expect(json['slotId'], 'splash1');
      expect(json['tolerateTimeout'], isNull);
      expect(json['hideSkipButton'], isNull);
      expect(json['expressSize'], isNull);
    });

    test('optional fields', () {
      const config = IOSSplashConfig(
        slotId: 'splash1',
        tolerateTimeout: 5.0,
        hideSkipButton: true,
      );
      final json = config.toJSON();
      expect(json['tolerateTimeout'], 5.0);
      expect(json['hideSkipButton'], true);
    });
  });

  group('IOSRewardedVideoConfig', () {
    test('defaults', () {
      const config = IOSRewardedVideoConfig(slotId: 'reward1');
      final json = config.toJSON();
      expect(json['slotId'], 'reward1');
      expect(json['loadingType'], PangleLoadingType.normal.index);
      expect(json['userId'], isNull);
    });

    test('all fields', () {
      const config = IOSRewardedVideoConfig(
        slotId: 'reward1',
        userId: 'user42',
        rewardName: 'coins',
        rewardAmount: 100,
        extra: 'extra_data',
        loadingType: PangleLoadingType.preload,
      );
      final json = config.toJSON();
      expect(json['userId'], 'user42');
      expect(json['rewardName'], 'coins');
      expect(json['rewardAmount'], 100);
      expect(json['extra'], 'extra_data');
      expect(json['loadingType'], PangleLoadingType.preload.index);
    });

    test('copyWith preserves original when no override', () {
      const original = IOSRewardedVideoConfig(
        slotId: 'reward1',
        userId: 'user1',
        rewardName: 'gold',
      );
      final copy = original.copyWith();
      expect(copy.slotId, 'reward1');
      expect(copy.userId, 'user1');
      expect(copy.rewardName, 'gold');
    });

    test('copyWith overrides specified fields only', () {
      const original = IOSRewardedVideoConfig(
        slotId: 'reward1',
        userId: 'user1',
        loadingType: PangleLoadingType.normal,
      );
      final copy = original.copyWith(
        userId: 'user2',
        loadingType: PangleLoadingType.preload,
      );
      expect(copy.slotId, 'reward1');
      expect(copy.userId, 'user2');
      expect(copy.loadingType, PangleLoadingType.preload);
    });
  });

  group('IOSBannerConfig', () {
    test('required fields', () {
      final config = IOSBannerConfig(
        slotId: 'banner1',
        expressSize: PangleExpressSize(width: 300, height: 100),
      );
      final json = config.toJSON();
      expect(json['slotId'], 'banner1');
      expect(json['interval'], isNull);
    });
  });

  group('IOSFullscreenVideoConfig', () {
    test('defaults', () {
      const config = IOSFullscreenVideoConfig(slotId: 'full1');
      final json = config.toJSON();
      expect(json['slotId'], 'full1');
      expect(json['loadingType'], PangleLoadingType.normal.index);
    });

    test('copyWith slotId', () {
      const original = IOSFullscreenVideoConfig(slotId: 'full1');
      final copy = original.copyWith(slotId: 'full2');
      expect(copy.slotId, 'full2');
      expect(copy.loadingType, original.loadingType);
    });
  });

  group('IOSDrawConfig', () {
    test('defaults', () {
      const config = IOSDrawConfig(slotId: 'draw1');
      final json = config.toJSON();
      expect(json['slotId'], 'draw1');
      expect(json['adCount'], 3);
      expect(json['expressSize'], isNull);
    });

    test('custom adCount', () {
      const config = IOSDrawConfig(slotId: 'draw1', adCount: 5);
      expect(config.toJSON()['adCount'], 5);
    });
  });

  group('IOSStreamConfig', () {
    test('defaults', () {
      const config = IOSStreamConfig(slotId: 'stream1');
      final json = config.toJSON();
      expect(json['slotId'], 'stream1');
      expect(json['adCount'], 1);
    });

    test('custom adCount', () {
      const config = IOSStreamConfig(slotId: 'stream1', adCount: 3);
      expect(config.toJSON()['adCount'], 3);
    });
  });

  group('PangleLoadingType enum', () {
    test('index values are stable', () {
      expect(PangleLoadingType.normal.index, 0);
      expect(PangleLoadingType.preload.index, 1);
      expect(PangleLoadingType.preloadOnly.index, 2);
    });
  });
}
