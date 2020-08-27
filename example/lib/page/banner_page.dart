import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/common/constant.dart';

class BannerPage extends StatefulWidget {
  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banner AD'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: BannerView(
                iOS: IOSBannerConfig(
                  slotId: kBannerExpressId,
                  imgSize: PangleImgSize.banner600_300,
                  isExpress: true,
                  expectSize: PangleExpectSize(width: 300),
                ),
                android: AndroidBannerConfig(
                  slotId: kBannerExpressId,
                  imgSize: PangleImgSize.banner600_300,
                  isExpress: true,
                  expectSize: PangleExpectSize(width: 100),
                ),
              ),
            ),
            Container(
              height: 200,
              alignment: Alignment.bottomLeft,
              child: BannerView(
                iOS: IOSBannerConfig(
                  slotId: kBannerId,
                  imgSize: PangleImgSize.banner600_300,
                  expectSize: PangleExpectSize(width: 100),
                ),
                android: AndroidBannerConfig(
                  slotId: kBannerId,
                  imgSize: PangleImgSize.banner600_150,
                  expectSize: PangleExpectSize(width: 200),
                ),
              ),
            ),
            BannerView(
              iOS: IOSBannerConfig(
                slotId: kBannerExpressId,
                imgSize: PangleImgSize.banner600_300,
                isExpress: true,
              ),
              android: AndroidBannerConfig(
                slotId: kBannerExpressId,
                imgSize: PangleImgSize.banner600_260,
                isExpress: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
