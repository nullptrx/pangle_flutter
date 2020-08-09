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
    pangle.requestPermissionIfNecessary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pangle Ad SDK Examples'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                pangle.loadSplashAd(
                  iOS: IOSSplashConfig(slotId: kSplashId),
                  android: AndroidSplashConfig(slotId: kSplashId),
                );
              },
              child: Text('Splash Ad'),
            ),
            RaisedButton(
              onPressed: () {
                pangle.loadRewardVideoAd(
                  iOS: IOSRewardedVideoConfig(slotId: kRewardedVideoId),
                  android: AndroidRewardedVideoConfig(slotId: kRewardedVideoId),
                );
              },
              child: Text('Reward Video Ad'),
            ),
            RaisedButton(
              onPressed: loadBannerAd,
              child: Text('Banner Ad'),
            ),
            RaisedButton(
              onPressed: loadFeedAd,
              child: Text('Feed Ad'),
            ),
          ],
        ),
      ),
    );
  }

  void loadBannerAd() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => BannerPage()));
  }

  void loadFeedAd() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => FeedPage()));
  }
}
