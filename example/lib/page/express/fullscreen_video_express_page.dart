import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';

class FullscreenVideoExpressPage extends StatefulWidget {
  @override
  _FullscreenVideoExpressPageState createState() =>
      _FullscreenVideoExpressPageState();
}

class _FullscreenVideoExpressPageState
    extends State<FullscreenVideoExpressPage> {
  bool _loaded = false;

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
              child: ElevatedButton(
                onPressed: _onTapLoad,
                child: Text('Load'),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _loaded ? _onTapShow : null,
                child: Text('Show Ad'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapLoad() async {
    final result = await pangle.loadFullscreenVideoAd(
      iOS: IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
      android: AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
    );

    setState(() {
      _loaded = result.ok;
    });
  }

  _onTapShow() async {
    final result = await pangle.loadFullscreenVideoAd(
      iOS: IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.normal,
      ),
      android: AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.normal,
      ),
    );
    print(jsonEncode(result));
    setState(() {
      _loaded = false;
    });
  }
}
