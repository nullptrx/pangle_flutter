import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';

class BannerExpressPage extends StatefulWidget {
  @override
  _BannerExpressPageState createState() => _BannerExpressPageState();
}

class _BannerExpressPageState extends State<BannerExpressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banner Express AD'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 600 / 260.0,
              child: BannerView(
                // key: _banner1Key,
                iOS: IOSBannerConfig(
                  slotId: kBannerExpressId600x260,
                  expressSize: PangleExpressSize(width: 600, height: 260),
                ),
                android: AndroidBannerConfig(
                  slotId: kBannerExpressId600x260,
                  expressSize: PangleExpressSize(width: 600, height: 260),
                ),
              ),
            ),
            Container(
              height: 260,
              child: BannerView(
                iOS: IOSBannerConfig(
                  slotId: kBannerExpressId600x260,
                  expressSize: PangleExpressSize(width: 600, height: 260),
                ),
                android: AndroidBannerConfig(
                  slotId: kBannerExpressId600x260,
                  expressSize: PangleExpressSize(width: 600, height: 260),
                ),
                onBannerViewCreated: (BannerViewController controller) {
                  controller.updateTouchableBounds([Rect.zero]);
                  controller.updateRestrictedBounds([Rect.zero]);
                },
                onClick: () {},
              ),
            ),
            SizedBox(height: 1080),
            Center(child: Text('--- 这是底线 ---')),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
