import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../common/ext.dart';
import 'banner/banner_list_page.dart';
import 'draw/draw_list_page.dart';
import 'feed/feed_list_page.dart';
import 'fullscreen/fullscreen_list_page.dart';
import 'reward/reward_list_page.dart';
import 'splash/splash_list_page.dart';
import 'stream/preroll_page.dart';
import 'waterfall/waterfall_page.dart';

mixin HomePageProviderStateMixin<T extends StatefulWidget> on State<T> {
  String? _sdkVersion;
  PangleTheme _themeStatus = PangleTheme.light;

  @override
  void initState() {
    super.initState();
    _loadSdkVersion();
    _loadThemeStatus();
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = <_MenuItem>[
      _MenuItem(
        title: 'SDK 主题',
        subtitle: _themeStatus == PangleTheme.dark ? '当前：夜间模式 Dark' : '当前：日间模式 Light',
        onTap: _showThemePicker,
      ),
      _MenuItem(title: '信息流广告', subtitle: 'Feed Ads', page: const FeedListPage()),
      _MenuItem(title: 'Draw 竖版视频', subtitle: 'Draw Video Ads', page: const DrawListPage()),
      _MenuItem(title: 'Banner 广告', subtitle: 'Banner Ads', page: const BannerListPage()),
      _MenuItem(title: '开屏广告', subtitle: 'Splash Ads', page: const SplashListPage()),
      _MenuItem(title: '激励视频', subtitle: 'Rewarded Video Ads', page: const RewardListPage()),
      _MenuItem(title: '全屏视频/新插屏', subtitle: 'Fullscreen & Interstitial Ads', page: const FullscreenListPage()),
      _MenuItem(title: '贴片广告', subtitle: 'Pre-roll Ad', page: const StreamPage()),
      _MenuItem(title: '瀑布流', subtitle: 'Waterfall Ads', page: const WaterfallPage()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pangle Flutter Demo'),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report),
              tooltip: '测试工具',
              onPressed: _showTestSuite,
            ),
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
                  onTap: item.onTap ?? () => context.navigateTo(item.page!),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const _testToolsChannel = MethodChannel('pangle_test_tools');

  Future<void> _showTestSuite() async {
    try {
      await _testToolsChannel.invokeMethod('showTestSuite');
    } catch (e) {
      debugPrint('showTestSuite error: $e');
    }
  }

  Future<void> _loadThemeStatus() async {
    try {
      final status = await pangle.getThemeStatus();
      if (mounted) setState(() => _themeStatus = status);
    } catch (_) {}
  }

  Future<void> _showThemePicker() async {
    final picked = await showDialog<PangleTheme>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择 SDK 主题'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, PangleTheme.light),
            child: const Text('日间模式 Light'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, PangleTheme.dark),
            child: const Text('夜间模式 Dark'),
          ),
        ],
      ),
    );
    if (picked == null) return;
    try {
      final result = await pangle.setThemeStatus(picked);
      if (mounted) setState(() => _themeStatus = result);
    } catch (_) {}
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
  final Widget? page;
  final VoidCallback? onTap;

  const _MenuItem({required this.title, required this.subtitle, this.page, this.onTap})
      : assert(page != null || onTap != null, '_MenuItem requires either page or onTap');
}
