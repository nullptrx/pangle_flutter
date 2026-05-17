import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';

class BannerPage extends StatefulWidget {
  final String title;
  final double width;
  final double height;

  const BannerPage({
    super.key,
    required this.title,
    required this.width,
    required this.height,
  });

  @override
  State<BannerPage> createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  bool _removed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!_removed)
              BannerView(
                iOS: IOSBannerConfig(
                  slotId: kIOSBannerExpressId,
                  expressSize: PangleExpressSize(
                    width: widget.width,
                    height: widget.height,
                  ),
                ),
                android: AndroidBannerConfig(
                  slotId: kAndroidBannerExpressId,
                  expressSize: PangleExpressSize(
                    width: widget.width,
                    height: widget.height,
                  ),
                ),
                onDislike: (message, enforce) {
                  setState(() => _removed = true);
                },
                onError: (code, message) {
                  debugPrint('BannerView error: $code, $message');
                },
              ),
            const SizedBox(height: 400),
          ],
        ),
      ),
    );
  }
}
