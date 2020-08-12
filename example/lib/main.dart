import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import 'common/constant.dart';
import 'page/banner_page.dart';
import 'page/feed_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pangle.init(
    iOS: IOSConfig(appId: kAppId),
    android: AndroidConfig(appId: kAppId),
  );
  await pangle.loadSplashAd(
    iOS: IOSSplashConfig(slotId: kSplashId),
    android: AndroidSplashConfig(slotId: kSplashId, isExpress: true),
  );
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    pangle.requestPermissionIfNecessary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pangle Flutter Examples'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RaisedButton(
              onPressed: _loadSplashAd,
              child: Text('Splash AD'),
            ),
            RaisedButton(
              onPressed: _loadRewardVideoAd,
              child: Text('Reward Video AD'),
            ),
            RaisedButton(
              onPressed: _loadBannerAd,
              child: Text('Banner AD'),
            ),
            RaisedButton(
              onPressed: _loadFeedAd,
              child: Text('Feed AD'),
            ),
            RaisedButton(
              onPressed: _loadInterstitialAd,
              child: Text('Interstitial AD'),
            ),
          ],
        ),
      ),
    );
  }

  _loadSplashAd() {
    pangle.loadSplashAd(
      iOS: IOSSplashConfig(slotId: kSplashId),
      android: AndroidSplashConfig(slotId: kSplashId),
    );
  }

  _loadRewardVideoAd() async {
    final result = await pangle.loadRewardVideoAd(
      iOS: IOSRewardedVideoConfig(slotId: kRewardedVideoId),
      android: AndroidRewardedVideoConfig(slotId: kRewardedVideoId),
    );
    print(jsonEncode(result));
  }

  void _loadBannerAd() {
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => BannerPage()));
  }

  void _loadFeedAd() {
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => FeedPage()));
  }

  void _loadInterstitialAd() async {
    final result = await pangle.loadInterstitialAd(
      iOS: IOSInterstitialAdConfig(slotId: kInterstitialId),
      android: AndroidInterstitialAdConfig(slotId: kInterstitialId),
    );
    print(jsonEncode(result));
  }
}
