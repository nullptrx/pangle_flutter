import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';
import '../../common/logger.dart';

class RewardedVideoExpressPage extends StatefulWidget {
  @override
  _RewardedVideoExpressPageState createState() =>
      _RewardedVideoExpressPageState();
}

class _RewardedVideoExpressPageState extends State<RewardedVideoExpressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewarded Video Express AD'),
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
    await pangle.loadRewardedVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
    );
  }

  _onTapShow() async {
    final result = await pangle.loadRewardedVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload,
      ),
    );
    logger.d(jsonEncode(result));
  }
}
