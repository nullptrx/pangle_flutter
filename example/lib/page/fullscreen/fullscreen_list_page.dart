import 'package:flutter/material.dart';

import '../../common/ext.dart';
import '../constant.dart';
import 'fullscreen_page.dart';

class FullscreenListPage extends StatelessWidget {
  const FullscreenListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(label: '全屏视频-横屏', androidId: kAndroidFullscreenLandscapeId, iosId: kIOSFullscreenLandscapeId),
      _Item(label: '全屏视频-竖屏', androidId: kAndroidFullscreenPortraitId, iosId: kIOSFullscreenPortraitId),
      _Item(label: '模板全屏视频-横屏', androidId: kAndroidFullscreenExpressLandscapeId, iosId: kIOSFullscreenLandscapeId),
      _Item(label: '模板全屏视频-竖屏', androidId: kAndroidFullscreenExpressPortraitId, iosId: kIOSFullscreenPortraitId),
      _Item(label: '新插屏-半屏横', androidId: kAndroidInterstitialHalfLandscapeId, iosId: kIOSInterstitialHalfId),
      _Item(label: '新插屏-半屏竖', androidId: kAndroidInterstitialHalfPortraitId, iosId: kIOSInterstitialHalfId),
      _Item(label: '新插屏-全屏横', androidId: kAndroidInterstitialFullLandscapeId, iosId: kIOSInterstitialFullId),
      _Item(label: '新插屏-全屏竖', androidId: kAndroidInterstitialFullPortraitId, iosId: kIOSInterstitialFullId),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('全屏视频/新插屏广告')),
      body: ListView.separated(
        separatorBuilder: (_, i) => const Divider(height: 1),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.label),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => context.navigateTo(FullscreenPage(
              title: item.label,
              androidSlotId: item.androidId,
              iosSlotId: item.iosId,
            )),
          );
        },
      ),
    );
  }
}

class _Item {
  final String label;
  final String androidId;
  final String iosId;

  const _Item({required this.label, required this.androidId, required this.iosId});
}
