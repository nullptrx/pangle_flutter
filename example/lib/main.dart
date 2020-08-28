import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'common/constant.dart';
import 'page/banner_page.dart';
import 'page/feed_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pangle.init(
    iOS: IOSConfig(appId: kAppId, logLevel: PangleLogLevel.debug),
    android: AndroidConfig(
      appId: kAppId,
      debug: true,
      allowShowNotify: true,
      allowShowPageWhenScreenLock: false,
    ),
  );
  await pangle.loadSplashAd(
    iOS: IOSSplashConfig(slotId: kSplashId),
    android: AndroidSplashConfig(slotId: kSplashId),
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
    pangle.loadRewardVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        isExpress: true,
        loadingType: PangleLoadingType.preload_only,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        isExpress: true,
        loadingType: PangleLoadingType.preload_only,
      ),
    );
    pangle.loadFullscreenVideoAd(
      iOS: IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        isExpress: true,
        loadingType: PangleLoadingType.preload_only,
      ),
      android: AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        isExpress: true,
        loadingType: PangleLoadingType.preload_only,
      ),
    );
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
              onPressed: _requestPermissions,
              child: Text('Request Permissions'),
            ),
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
            RaisedButton(
              onPressed: _loadFullscreenVideoAd,
              child: Text('FullScreenVideo AD'),
            ),
          ],
        ),
      ),
    );
  }

  void _requestPermissions() async {
//    pangle.requestPermissionIfNecessary();

    await [Permission.location, Permission.phone, Permission.storage].request();
  }

  _loadSplashAd() {
    pangle.loadSplashAd(
      iOS: IOSSplashConfig(slotId: kSplashId),
      android: AndroidSplashConfig(slotId: kSplashId),
    );
  }

  _loadRewardVideoAd() async {
    final result = await pangle.loadRewardVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        isExpress: true,
        loadingType: PangleLoadingType.preload,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        isExpress: true,
        loadingType: PangleLoadingType.preload,
      ),
    );
    print(jsonEncode(result));
  }

  void _loadBannerAd() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => BannerPage()),
    );
  }

  void _loadFeedAd() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => FeedPage()),
    );
  }

  void _loadInterstitialAd() async {
    final result = await pangle.loadInterstitialAd(
      iOS: IOSInterstitialConfig(
        slotId: kInterstitialExpressId,
        isExpress: true,

        /// 该宽高为你申请的广告位宽高，请根据实际情况赋值
        imgSize: PangleImgSize.interstitial600_400,
      ),
      android: AndroidInterstitialConfig(
        slotId: kInterstitialExpressId,
        isExpress: true,
      ),
    );
    print(jsonEncode(result));
  }

  void _loadFullscreenVideoAd() async {
    final result = await pangle.loadFullscreenVideoAd(
      iOS: IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        isExpress: true,
        loadingType: PangleLoadingType.preload,
      ),
      android: AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        isExpress: true,
        loadingType: PangleLoadingType.preload,
      ),
    );
    print(jsonEncode(result));
  }
}
