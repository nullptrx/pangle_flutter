import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';

class BannerPage extends StatelessWidget {
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
              android: AndroidBannerConfig(
                slotId: kBannerId,
                isExpress: false,
                imgSize: PangleImgSize.banner600_150,
              ),
            ),
            BannerView(
              android: AndroidBannerConfig(
                slotId: kBannerId,
                isExpress: false,
                imgSize: PangleImgSize.banner600_300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
