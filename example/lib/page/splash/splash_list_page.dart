import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';

class SplashListPage extends StatelessWidget {
  const SplashListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SplashItem(label: '全屏开屏', androidId: kAndroidSplashFullId, iosId: kIOSSplashNormalId),
      _SplashItem(label: '半全屏开屏', androidId: kAndroidSplashHalfId, iosId: kIOSSplashNormalId, isHalfSize: true),
      _SplashItem(label: '模板开屏', androidId: kAndroidSplashExpressId, iosId: kIOSSplashExpressId),
      _SplashItem(label: '横版模板开屏', androidId: kAndroidSplashLandscapeExpressId, iosId: kIOSSplashNormalId),
      _SplashItem(label: '横版开屏', androidId: kAndroidSplashLandscapeId, iosId: kIOSSplashNormalId),
      _SplashItem(label: '小手互动开屏', androidId: kAndroidSplashInteractiveSmallId, iosId: kIOSSplashNormalId),
      _SplashItem(label: '摇一摇开屏', androidId: kAndroidSplashShakeId, iosId: kIOSSplashNormalId),
      _SplashItem(label: '扭一扭开屏', androidId: kAndroidSplashTwistId, iosId: kIOSSplashNormalId),
      _SplashItem(label: '上滑开屏', androidId: kAndroidSplashSwipeId, iosId: kIOSSplashNormalId),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('开屏广告')),
      body: ListView.separated(
        separatorBuilder: (_, i) => const Divider(height: 1),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.label),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => _loadSplash(context, item),
          );
        },
      ),
    );
  }

  Future<void> _loadSplash(BuildContext context, _SplashItem item) async {
    final slotId = Platform.isIOS ? item.iosId : item.androidId;
    // iOS 半全屏：adSize = 屏幕宽 × (屏幕高 - 100)，对应 iOS demo 的半屏高度
    final iosExpressSize = item.isHalfSize
        ? PangleExpressSize(
            width: kPangleScreenWidth,
            height: kPangleScreenHeight - 100,
          )
        : null;
    try {
      await pangle.loadSplashAd(
        iOS: IOSSplashConfig(slotId: slotId, expressSize: iosExpressSize),
        android: AndroidSplashConfig(slotId: slotId, isHalfSize: item.isHalfSize),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }
}

class _SplashItem {
  final String label;
  final String androidId;
  final String iosId;
  final bool isHalfSize;
  const _SplashItem({
    required this.label,
    required this.androidId,
    required this.iosId,
    this.isHalfSize = false,
  });
}
