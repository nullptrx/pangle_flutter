import 'package:flutter/material.dart';

import '../../common/ext.dart';
import 'ec_mall_page.dart';
import 'feed_icon_page.dart';
import 'feed_page.dart';

class FeedListPage extends StatelessWidget {
  const FeedListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('信息流广告')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('模板渲染信息流（单条）'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => context.navigateTo(const FeedPage()),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('模板渲染信息流视频'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => context.navigateTo(const FeedVideoPage()),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('模板渲染信息流图标'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => context.navigateTo(const FeedIconPage()),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('电商 Mall'),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => context.navigateTo(const EcMallPage()),
          ),
        ],
      ),
    );
  }
}
