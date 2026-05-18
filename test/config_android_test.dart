import 'package:flutter_test/flutter_test.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidConfig', () {
    test('required fields only', () {
      const config = AndroidConfig(appId: 'app123');
      final json = config.toJSON();
      expect(json['appId'], 'app123');
      expect(json['titleBarTheme'], AndroidTitleBarTheme.light.index);
      expect(json['supportMultiProcess'], false);
      expect(json['debug'], isNull);
      expect(json['allowShowNotify'], isNull);
    });

    test('all fields', () {
      const config = AndroidConfig(
        appId: 'app123',
        debug: true,
        allowShowNotify: false,
        supportMultiProcess: true,
        isPaidApp: true,
        useTextureView: false,
        titleBarTheme: AndroidTitleBarTheme.dark,
        directDownloadNetworkType: [AndroidDirectDownloadNetworkType.kWiFi],
      );
      final json = config.toJSON();
      expect(json['appId'], 'app123');
      expect(json['debug'], true);
      expect(json['allowShowNotify'], false);
      expect(json['supportMultiProcess'], true);
      expect(json['paid'], true);
      expect(json['useTextureView'], false);
      expect(json['titleBarTheme'], AndroidTitleBarTheme.dark.index);
      expect(
        json['directDownloadNetworkType'],
        contains(AndroidDirectDownloadNetworkType.kWiFi),
      );
    });

    test('titleBarTheme enum index matches ordinal', () {
      expect(AndroidTitleBarTheme.light.index, 0);
      expect(AndroidTitleBarTheme.dark.index, 1);
      expect(AndroidTitleBarTheme.noTitleBar.index, 2);
    });

    test('location serializes latitude/longitude', () {
      final config = AndroidConfig(
        appId: 'app123',
        location: PangleLocation(latitude: 31.23, longitude: 121.47),
      );
      final json = config.toJSON();
      final loc = json['location'] as Map<String, double>?;
      expect(loc, isNotNull);
      expect(loc!['latitude'], closeTo(31.23, 0.001));
      expect(loc['longitude'], closeTo(121.47, 0.001));
    });
  });

  group('AndroidSplashConfig', () {
    test('required field only', () {
      const config = AndroidSplashConfig(slotId: 'slot1');
      final json = config.toJSON();
      expect(json['slotId'], 'slot1');
      expect(json['isExpress'], false);
      expect(json['isHalfSize'], false);
      expect(json['isSupportDeepLink'], true);
    });

    test('isHalfSize flag', () {
      const config = AndroidSplashConfig(slotId: 'slot1', isHalfSize: true);
      expect(config.toJSON()['isHalfSize'], true);
    });

    test('optional fields', () {
      const config = AndroidSplashConfig(
        slotId: 'slot1',
        tolerateTimeout: 3.5,
        hideSkipButton: true,
        isExpress: true,
        isHalfSize: true,
        isSupportDeepLink: false,
      );
      final json = config.toJSON();
      expect(json['tolerateTimeout'], 3.5);
      expect(json['hideSkipButton'], true);
      expect(json['isExpress'], true);
      expect(json['isHalfSize'], true);
      expect(json['isSupportDeepLink'], false);
    });
  });

  group('AndroidRewardedVideoConfig', () {
    test('required field only', () {
      final config = AndroidRewardedVideoConfig(slotId: 'slot1');
      final json = config.toJSON();
      expect(json['slotId'], 'slot1');
      expect(json['isSupportDeepLink'], true);
      expect(json['isVertical'], true);
    });

    test('copyWith preserves original when no override', () {
      final original = AndroidRewardedVideoConfig(
        slotId: 'slot1',
        userId: 'user1',
        rewardName: 'coins',
      );
      final copy = original.copyWith();
      expect(copy.slotId, 'slot1');
      expect(copy.userId, 'user1');
      expect(copy.rewardName, 'coins');
    });

    test('copyWith overrides specified fields', () {
      final original = AndroidRewardedVideoConfig(
        slotId: 'slot1',
        userId: 'user1',
      );
      final copy = original.copyWith(slotId: 'slot2', userId: 'user2');
      expect(copy.slotId, 'slot2');
      expect(copy.userId, 'user2');
    });
  });

  group('AndroidBannerConfig', () {
    test('required fields', () {
      final config = AndroidBannerConfig(
        slotId: 'banner1',
        expressSize: PangleExpressSize(width: 300, height: 100),
      );
      final json = config.toJSON();
      expect(json['slotId'], 'banner1');
      expect(json['isSupportDeepLink'], true);
      expect((json['expressSize'] as Map)['width'], isNotNull);
    });

    test('optional interval', () {
      final config = AndroidBannerConfig(
        slotId: 'banner1',
        expressSize: PangleExpressSize(width: 300, height: 100),
        interval: 60,
      );
      expect(config.toJSON()['interval'], 60);
    });
  });

  group('AndroidFeedConfig', () {
    test('serializes count and expressSize', () {
      final config = AndroidFeedConfig(
        slotId: 'feed1',
        expressSize: PangleExpressSize(width: 375, height: 120),
        count: 3,
      );
      final json = config.toJSON();
      expect(json['slotId'], 'feed1');
      expect(json['count'], 3);
      expect((json['expressSize'] as Map)['width'], isNotNull);
    });
  });

  group('AndroidFeedIconConfig', () {
    test('defaults', () {
      const config = AndroidFeedIconConfig(slotId: 'icon1');
      final json = config.toJSON();
      expect(json['slotId'], 'icon1');
      expect(json['adCount'], 1);
      expect(json['supportIconStyle'], true);
      final size = json['expressSize'] as Map;
      expect(size['width'], 160.0);
      expect(size['height'], 0.0);
    });

    test('custom width', () {
      const config = AndroidFeedIconConfig(
        slotId: 'icon1',
        expressViewWidth: 200,
        adCount: 2,
      );
      final json = config.toJSON();
      expect(json['adCount'], 2);
      expect((json['expressSize'] as Map)['width'], 200.0);
    });
  });

  group('AndroidDrawConfig', () {
    test('defaults', () {
      const config = AndroidDrawConfig(slotId: 'draw1');
      final json = config.toJSON();
      expect(json['slotId'], 'draw1');
      expect(json['adCount'], 2);
      expect(json['isSupportDeepLink'], true);
      expect(json['expressSize'], isNull);
    });

    test('custom adCount', () {
      const config = AndroidDrawConfig(slotId: 'draw1', adCount: 5);
      expect(config.toJSON()['adCount'], 5);
    });
  });

  group('AndroidStreamConfig', () {
    test('defaults', () {
      const config = AndroidStreamConfig(slotId: 'stream1');
      final json = config.toJSON();
      expect(json['slotId'], 'stream1');
      expect(json['adCount'], 1);
      expect(json['isSupportDeepLink'], true);
      expect(json['imgSize'], isNull);
    });

    test('with imgSize', () {
      final config = AndroidStreamConfig(
        slotId: 'stream1',
        imgSize: PangleSize(width: 640, height: 320),
      );
      final size = config.toJSON()['imgSize'] as Map;
      expect(size['width'], isNot(0));
      expect(size['height'], isNot(0));
    });
  });

  group('AndroidFullscreenVideoConfig', () {
    test('defaults', () {
      final config = AndroidFullscreenVideoConfig(slotId: 'full1');
      final json = config.toJSON();
      expect(json['slotId'], 'full1');
      expect(json['isSupportDeepLink'], true);
      expect(json['orientation'], PangleOrientation.vertical.index);
      expect(json['loadingType'], PangleLoadingType.normal.index);
    });

    test('copyWith slotId', () {
      final original = AndroidFullscreenVideoConfig(slotId: 'full1');
      final copy = original.copyWith(slotId: 'full2');
      expect(copy.slotId, 'full2');
      expect(copy.orientation, original.orientation);
    });
  });
}
