import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';

class BannerExpressPage extends StatelessWidget {
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
            BannerView(
              iOS: IOSBannerConfig(
                slotId: kBannerExpressId,
                expressSize: PangleExpressSize(width: 600, height: 200),
              ),
              android: AndroidBannerConfig(
                slotId: kBannerExpressId,
                expressSize: PangleExpressSize(width: 600, height: 200),
              ),
            ),
            BannerView(
              iOS: IOSBannerConfig(
                slotId: kBannerExpressId,
                expressSize: PangleExpressSize.aspectRatio(1.667),
              ),
              android: AndroidBannerConfig(
                slotId: kBannerExpressId,
                expressSize: PangleExpressSize.aspectRatio(1.667),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
