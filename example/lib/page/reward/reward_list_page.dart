import 'package:flutter/material.dart';

import '../../common/ext.dart';
import '../constant.dart';
import 'reward_page.dart';

class RewardListPage extends StatelessWidget {
  const RewardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _RewardItem(
        label: '激励视频-横屏',
        androidId: kAndroidRewardLandscapeId,
        iosId: kIOSRewardLandscapeId,
        isVertical: false,
      ),
      _RewardItem(
        label: '激励视频-竖屏',
        androidId: kAndroidRewardPortraitId,
        iosId: kIOSRewardPortraitId,
        isVertical: true,
      ),
      _RewardItem(
        label: '模板激励视频-横屏',
        androidId: kAndroidRewardExpressLandscapeId,
        iosId: kIOSRewardLandscapeId,
        isVertical: false,
      ),
      _RewardItem(
        label: '模板激励视频-竖屏',
        androidId: kAndroidRewardExpressPortraitId,
        iosId: kIOSRewardPortraitId,
        isVertical: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('激励视频广告')),
      body: ListView.separated(
        separatorBuilder: (_, i) => const Divider(height: 1),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.label),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => context.navigateTo(RewardPage(
              title: item.label,
              androidSlotId: item.androidId,
              iosSlotId: item.iosId,
              isVertical: item.isVertical,
            )),
          );
        },
      ),
    );
  }
}

class _RewardItem {
  final String label;
  final String androidId;
  final String iosId;
  final bool isVertical;

  const _RewardItem({
    required this.label,
    required this.androidId,
    required this.iosId,
    required this.isVertical,
  });
}
