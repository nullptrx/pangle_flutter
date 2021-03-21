import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';

class InterstitialExpressPage extends StatefulWidget {
  @override
  _InterstitialExpressPageState createState() =>
      _InterstitialExpressPageState();
}

class _InterstitialExpressPageState extends State<InterstitialExpressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interstitial Express AD'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: _onTapShow,
                child: Text('Show Ad'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapShow() async {
    final width = kPangleScreenWidth - 30;
    final height = width / 1.667;

    final result = await pangle.loadInterstitialAd(
      iOS: IOSInterstitialConfig(
        slotId: kInterstitialExpressId3x2,
        // 该宽高为你申请的广告位宽高，请根据实际情况赋值
        expressSize: PangleExpressSize(width: width, height: height),
      ),
      android: AndroidInterstitialConfig(
        slotId: kInterstitialExpressId3x2,
        // 该宽高为你申请的广告位宽高，请根据实际情况赋值
        expressSize: PangleExpressSize.widthPercent(0.8, aspectRatio: 1.667),
      ),
    );
    print(jsonEncode(result));
  }
}
