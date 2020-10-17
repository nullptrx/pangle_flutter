import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';

class BannerExpressPage extends StatefulWidget {
  @override
  _BannerExpressPageState createState() => _BannerExpressPageState();
}

class _BannerExpressPageState extends State<BannerExpressPage> {
  bool _enableClickAction = true;

  final _banner1Key = GlobalKey<BannerViewState>();

  final _banner2Key = GlobalKey<BannerViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banner Express AD'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _enableClickAction = !_enableClickAction;
          });
          _banner1Key.currentState
              .setUserInteractionEnabled(_enableClickAction);
          _banner2Key.currentState
              .setUserInteractionEnabled(_enableClickAction);
        },
        child: Icon(_enableClickAction ? Icons.lock_open : Icons.lock_outline),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            BannerView(
              key: _banner1Key,
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
              key: _banner2Key,
              iOS: IOSBannerConfig(
                slotId: kBannerExpressId,
                expressSize: PangleExpressSize.aspectRatio(1.667),
                isUserInteractionEnabled: false,
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
