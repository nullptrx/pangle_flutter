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
  bool _loaded = false;

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
    final result = await pangle.loadRewardedVideoAd(
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

    setState(() {
      _loaded = result['code'] == 0;
    });
  }

  _onTapShow() async {
    final result = await pangle.loadRewardedVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoId,
        isExpress: false,
        loadingType: PangleLoadingType.normal,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoId,
        isExpress: false,
        loadingType: PangleLoadingType.normal,
      ),
    );
    logger.d(jsonEncode(result));
    setState(() {
      _loaded = false;
    });
  }
}
