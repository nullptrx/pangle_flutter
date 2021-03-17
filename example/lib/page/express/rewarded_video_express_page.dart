import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../common/constant.dart';

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
              child: ElevatedButton(
                onPressed: _onTapLoad,
                child: Text('Load'),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _onTapShow,
                child: Text('Show ad'),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _onTapShowAndLoad,
                child: Text('Show ad and preload'),
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
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
    );
    print(jsonEncode(result));
  }

  _onTapShow() async {
    final result = await pangle.loadRewardedVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.normal,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.normal,
      ),
    );
    print(jsonEncode(result));
  }

  _onTapShowAndLoad() async {
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
    print(jsonEncode(result));
  }
}
