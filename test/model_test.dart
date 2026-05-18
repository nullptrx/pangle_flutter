import 'package:flutter_test/flutter_test.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

void main() {
  group('PangleAd', () {
    test('empty() returns failure state', () {
      final ad = PangleAd.empty();
      expect(ad.code, -1);
      expect(ad.ok, false);
      expect(ad.data, isEmpty);
      expect(ad.count, 0);
    });

    test('fromJsonMap parses success response', () {
      final ad = PangleAd.fromJsonMap({
        'code': 0,
        'message': null,
        'count': 2,
        'data': ['id1', 'id2'],
      });
      expect(ad.code, 0);
      expect(ad.ok, true);
      expect(ad.count, 2);
      expect(ad.data, ['id1', 'id2']);
    });

    test('fromJsonMap handles null data list', () {
      final ad = PangleAd.fromJsonMap({
        'code': -1,
        'message': 'error',
        'count': 0,
        'data': null,
      });
      expect(ad.data, isEmpty);
      expect(ad.ok, false);
    });
  });

  group('PangleResult', () {
    test('fromJson null returns code -1', () {
      final result = PangleResult.fromJson(null);
      expect(result.code, -1);
      expect(result.ok, false);
    });

    test('fromJson success', () {
      final result = PangleResult.fromJson({'code': 0, 'message': null});
      expect(result.ok, true);
      expect(result.message, isNull);
    });

    test('fromJson failure with message', () {
      final result = PangleResult.fromJson({'code': -1, 'message': 'timeout'});
      expect(result.ok, false);
      expect(result.message, 'timeout');
    });
  });

  group('PangleVerifyResult', () {
    test('fromJson null returns code -1', () {
      final result = PangleVerifyResult.fromJson(null);
      expect(result.code, -1);
      expect(result.isVerify, false);
    });

    test('isVerify true when verify=true', () {
      final result = PangleVerifyResult.fromJson({
        'code': 0,
        'message': null,
        'verify': true,
      });
      expect(result.isVerify, true);
    });

    test('isVerify false when verify=false', () {
      final result = PangleVerifyResult.fromJson({
        'code': 0,
        'message': null,
        'verify': false,
      });
      expect(result.isVerify, false);
    });

    test('isVerify false when verify absent', () {
      final result = PangleVerifyResult.fromJson({'code': 0, 'message': null});
      expect(result.isVerify, false);
    });
  });

  group('PangleSplashResult', () {
    test('fromJson null returns unknown type', () {
      final result = PangleSplashResult.fromJson(null);
      expect(result.code, -1);
      expect(result.type, PangleSplashCloseType.unknown);
    });

    test('fromJson parses close type by index', () {
      final result = PangleSplashResult.fromJson({
        'code': 0,
        'message': '',
        'type': PangleSplashCloseType.clickSkip.index,
      });
      expect(result.type, PangleSplashCloseType.clickSkip);
    });

    test('fromJson handles out-of-range type index', () {
      final result = PangleSplashResult.fromJson({
        'code': 0,
        'message': '',
        'type': 999,
      });
      expect(result.type, PangleSplashCloseType.unknown);
    });
  });

  group('PangleDrawAd', () {
    test('empty() returns failure state', () {
      final ad = PangleDrawAd.empty();
      expect(ad.code, -1);
      expect(ad.ok, false);
      expect(ad.data, isEmpty);
    });

    test('fromJsonMap parses success response', () {
      final ad = PangleDrawAd.fromJsonMap({
        'code': 0,
        'message': null,
        'count': 3,
        'data': ['d1', 'd2', 'd3'],
      });
      expect(ad.ok, true);
      expect(ad.count, 3);
      expect(ad.data.length, 3);
    });

    test('fromJsonMap handles null data', () {
      final ad = PangleDrawAd.fromJsonMap({
        'code': -1,
        'message': 'no fill',
        'count': 0,
        'data': null,
      });
      expect(ad.data, isEmpty);
    });
  });

  group('StreamAdItem', () {
    test('fromJsonMap parses all fields', () {
      final item = StreamAdItem.fromJsonMap({
        'id': 'stream_001',
        'imageMode': 3,
        'videoUrl': 'https://example.com/video.mp4',
        'videoDuration': 15.5,
        'imageUrl': 'https://example.com/cover.jpg',
        'title': 'Ad Title',
        'description': 'Ad description',
      });
      expect(item.id, 'stream_001');
      expect(item.imageMode, 3);
      expect(item.videoUrl, 'https://example.com/video.mp4');
      expect(item.videoDuration, 15.5);
      expect(item.imageUrl, 'https://example.com/cover.jpg');
      expect(item.title, 'Ad Title');
      expect(item.description, 'Ad description');
    });

    test('fromJsonMap defaults missing fields', () {
      final item = StreamAdItem.fromJsonMap({'id': 'x'});
      expect(item.id, 'x');
      expect(item.imageMode, 0);
      expect(item.videoDuration, 0.0);
      expect(item.videoUrl, isNull);
      expect(item.title, isNull);
    });

    test('videoDuration converts int to double', () {
      final item = StreamAdItem.fromJsonMap({
        'id': 'x',
        'videoDuration': 30,
      });
      expect(item.videoDuration, 30.0);
      expect(item.videoDuration, isA<double>());
    });
  });

  group('PangleStreamAd', () {
    test('empty() returns failure state', () {
      final ad = PangleStreamAd.empty();
      expect(ad.code, -1);
      expect(ad.ok, false);
      expect(ad.data, isEmpty);
    });

    test('fromJsonMap parses list of items', () {
      final ad = PangleStreamAd.fromJsonMap({
        'code': 0,
        'message': null,
        'count': 2,
        'data': [
          {'id': 's1', 'videoUrl': 'https://cdn.example.com/1.mp4'},
          {'id': 's2', 'videoUrl': 'https://cdn.example.com/2.mp4'},
        ],
      });
      expect(ad.ok, true);
      expect(ad.data.length, 2);
      expect(ad.data.first.id, 's1');
      expect(ad.data.last.videoUrl, 'https://cdn.example.com/2.mp4');
    });

    test('fromJsonMap handles null data', () {
      final ad = PangleStreamAd.fromJsonMap({
        'code': -1,
        'message': 'error',
        'count': 0,
        'data': null,
      });
      expect(ad.data, isEmpty);
    });
  });

  group('PangleLocation', () {
    test('toJson serializes lat/lng', () {
      final loc = PangleLocation(latitude: 39.9, longitude: 116.4);
      final json = loc.toJson();
      expect(json['latitude'], closeTo(39.9, 0.001));
      expect(json['longitude'], closeTo(116.4, 0.001));
    });

    test('defaults to 0,0', () {
      final loc = PangleLocation();
      expect(loc.latitude, 0.0);
      expect(loc.longitude, 0.0);
    });
  });
}
