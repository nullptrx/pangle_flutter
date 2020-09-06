import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/common/constant.dart';

class BannerPage extends StatefulWidget {
  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  @override
  void initState() {
    super.initState();
    var pangleExpressSize = PangleExpressSize(width: 600, height: 500);
    print(pangleExpressSize.toJSON());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banner AD'),
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
                slotId: kBannerId,
                isExpress: false,
                imgSize: PangleImgSize.banner600_300,
              ),
              android: AndroidBannerConfig(
                slotId: kBannerId,
                isExpress: false,
                imgSize: PangleImgSize.banner600_300,
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
            FlutterLogo(),
          ],
        ),
      ),
    );
  }
}
