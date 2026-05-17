import 'package:flutter/material.dart';

import '../../common/ext.dart';
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
          const ListTile(
            title: Text('模板渲染信息流图标'),
            subtitle: Text('需要 loadFeedIconAd 接口（Phase 2 实现）'),
            trailing: Icon(Icons.lock_outline),
            enabled: false,
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text('电商 Mall'),
            subtitle: Text('需要 SDK 特殊支持（Phase 3 实现）'),
            trailing: Icon(Icons.lock_outline),
            enabled: false,
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text('原生信息流（自渲���）'),
            subtitle: Text('Flutter 中自渲染价值低，暂不支持'),
            trailing: Icon(Icons.block),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
