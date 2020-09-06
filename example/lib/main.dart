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
    iOS: IOSConfig(
      appId: kAppId,
      logLevel: PangleLogLevel.debug,
    ),
    android: AndroidConfig(
      appId: kAppId,
      debug: true,
      allowShowNotify: true,
      allowShowPageWhenScreenLock: false,
    ),
  );
  await pangle.loadSplashAd(
    iOS: IOSSplashConfig(
      slotId: kSplashId,
      isExpress: false,
    ),
    android: AndroidSplashConfig(
      slotId: kSplashId,
      isExpress: false,
      loadAwait: false,
    ),
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
        loadingType: PangleLoadingType.preload_only,
        expressSize: PangleExpressSize.aspectRatio(16 / 9),
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
        expressSize: PangleExpressSize.aspectRatio(16 / 9),
      ),
    );
    pangle.loadFullscreenVideoAd(
      iOS: IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
        expressSize: PangleExpressSize.aspectRatio(16 / 9),
      ),
      android: AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
        expressSize: PangleExpressSize.aspectRatio(16 / 9),
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
      iOS: IOSSplashConfig(slotId: kSplashId, isExpress: false),
      android: AndroidSplashConfig(slotId: kSplashId, isExpress: false),
    );
  }

  _loadRewardVideoAd() async {
    final result = await pangle.loadRewardVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload,
        expressSize: PangleExpressSize.aspectRatio(16 / 9),
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload,
        expressSize: PangleExpressSize.aspectRatio(16 / 9),
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
    final width = kScreenWidth - 30;
    final height = width / 1.667;

    final result = await pangle.loadInterstitialAd(
      iOS: IOSInterstitialConfig(
        slotId: kInterstitialExpressId,
        expressSize: PangleExpressSize(width: width, height: height),
        // 该宽高为你申请的广告位宽高，请根据实际情况赋值
        // imgSize: PangleImgSize.interstitial600_400,
      ),
      android: AndroidInterstitialConfig(
        slotId: kInterstitialExpressId,
        expressSize: PangleExpressSize(width: width, height: height),
      ),
    );
    print(jsonEncode(result));
  }

  void _loadFullscreenVideoAd() async {
    final result = await pangle.loadFullscreenVideoAd(
      iOS: IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload,
        expressSize: PangleExpressSize.aspectRatio(16 / 9),
      ),
      android: AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preload,
        expressSize: PangleExpressSize.aspectRatio(16 / 9),
      ),
    );
    print(jsonEncode(result));
  }
}
