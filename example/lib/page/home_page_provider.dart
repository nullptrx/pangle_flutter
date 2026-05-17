import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../common/ext.dart';
import 'banner/banner_list_page.dart';
import 'draw/draw_list_page.dart';
import 'feed/feed_list_page.dart';
import 'fullscreen/fullscreen_list_page.dart';
import 'reward/reward_list_page.dart';
import 'splash/splash_list_page.dart';
import 'stream/stream_page.dart';
import 'waterfall/waterfall_page.dart';

mixin HomePageProviderStateMixin<T extends StatefulWidget> on State<T> {
  String? _sdkVersion;

  @override
  void initState() {
    super.initState();
    _loadSdkVersion();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = <_MenuItem>[
      _MenuItem(title: '信息流广告', subtitle: 'Feed Ads', page: const FeedListPage()),
      _MenuItem(title: 'Draw 竖版视频', subtitle: 'Draw Video Ads', page: const DrawListPage()),
      _MenuItem(title: 'Banner 广告', subtitle: 'Banner Ads', page: const BannerListPage()),
      _MenuItem(title: '开屏广告', subtitle: 'Splash Ads', page: const SplashListPage()),
      _MenuItem(title: '激励视频', subtitle: 'Rewarded Video Ads', page: const RewardListPage()),
      _MenuItem(title: '全屏视频/新插屏', subtitle: 'Fullscreen & Interstitial Ads', page: const FullscreenListPage()),
      _MenuItem(title: '流媒体自定义播放', subtitle: 'Stream Custom Player', page: const StreamPage()),
      _MenuItem(title: '瀑布流', subtitle: 'Waterfall Ads', page: const WaterfallPage()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pangle Flutter Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            tooltip: '请求权限',
            onPressed: requestPermissions,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_sdkVersion != null)
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'SDK Version: $_sdkVersion',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              separatorBuilder: (_, i) => const Divider(height: 1),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  trailing: const Icon(Icons.navigate_next),
                  onTap: () => context.navigateTo(item.page),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSdkVersion() async {
    try {
      final version = await pangle.getSdkVersion();
      if (mounted) setState(() => _sdkVersion = version);
    } catch (_) {}
  }

  void requestPermissions() {
    if (Platform.isIOS) {
      _requestPermissionsOnIOS();
    } else {
      _requestPermissionsOnAndroid();
    }
  }

  void _requestPermissionsOnAndroid() {
    pangle.requestPermissionIfNecessary();
  }

  void _requestPermissionsOnIOS() async {
    var status = await pangle.getTrackingAuthorizationStatus();
    if (status == PangleAuthorizationStatus.notDetermined) {
      await pangle.requestTrackingAuthorization();
    }
  }
}

class _MenuItem {
  final String title;
  final String subtitle;
  final Widget page;

  const _MenuItem({required this.title, required this.subtitle, required this.page});
}
