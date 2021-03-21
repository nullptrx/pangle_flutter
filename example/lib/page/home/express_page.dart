import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/ext.dart';
import '../../page/express/banner_express_page.dart';
import '../../page/express/feed_express_page.dart';
import '../../page/express/fullscreen_video_express_page.dart';
import '../../page/express/interstitial_express_page.dart';
import '../../page/express/rewarded_video_express_page.dart';

class ExpressPage extends StatefulWidget {
  @override
  _ExpressPageState createState() => _ExpressPageState();
}

class _ExpressPageState extends State<ExpressPage> {
  final pages = {
    'Rewarded Video Express AD': RewardedVideoExpressPage(),
    'Banner Express AD': BannerExpressPage(),
    'Feed Express AD': FeedExpressPage(),
    'Interstitial Express AD': InterstitialExpressPage(),
    'FullScreenVideo Express AD': FullscreenVideoExpressPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Express Examples'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: pages.length,
          itemBuilder: (context, index) {
            var titles = pages.keys.toList();
            final title = titles[index];
            return ListTile(
              title: Text(title),
              trailing: Icon(Icons.navigate_next),
              onTap: () => _onTapItem(title),
            );
          },
        ),
      ),
    );
  }

  _onTapItem(String title) {
    context.navigateTo(pages[title]);
  }
}
