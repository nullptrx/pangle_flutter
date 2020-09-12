import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';
import '../../common/logger.dart';

class RewardedVideoPage extends StatefulWidget {
  @override
  _RewardedVideoPageState createState() => _RewardedVideoPageState();
}

class _RewardedVideoPageState extends State<RewardedVideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewarded Video AD'),
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
        slotId: kRewardedVideoId,
        isExpress: false,
        loadingType: PangleLoadingType.preload_only,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoId,
        isExpress: false,
        loadingType: PangleLoadingType.preload_only,
      ),
    );
  }

  _onTapShow() async {
    final result = await pangle.loadRewardedVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoId,
        isExpress: false,
        loadingType: PangleLoadingType.preload,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoId,
        isExpress: false,
        loadingType: PangleLoadingType.preload,
      ),
    );
    logger.d(jsonEncode(result));
  }
}
