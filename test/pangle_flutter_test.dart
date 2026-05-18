import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannel smoke', () {
    const channel = MethodChannel('nullptrx.github.io/pangle');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall call) async {
        return switch (call.method) {
          'getSdkVersion' => '5.4.0.0',
          _ => null,
        };
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('getSdkVersion returns a version string', () async {
      final version = await pangle.getSdkVersion();
      expect(version, isNotNull);
    });
  });
}
