import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';
import '../../common/logger.dart';

class FullscreenVideoExpressPage extends StatefulWidget {
  @override
  _FullscreenVideoExpressPageState createState() =>
      _FullscreenVideoExpressPageState();
}

class _FullscreenVideoExpressPageState
    extends State<FullscreenVideoExpressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fullscreen Video AD'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: RaisedButton(
                onPressed: _onTapLoad,
                child: Text('Load'),
              ),
            ),
            Center(
              child: RaisedButton(
                onPressed: _onTapShow,
                child: Text('Show Ad'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapLoad() async {
    await pangle.loadFullscreenVideoAd(
      iOS: IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
      android: AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
    );
  }

  _onTapShow() async {
    final result = await pangle.loadFullscreenVideoAd(
      iOS: IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload,
      ),
      android: AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload,
      ),
    );
    logger.d(jsonEncode(result));
  }
}
