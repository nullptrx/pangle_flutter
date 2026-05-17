import 'package:flutter/material.dart';

import '../../common/ext.dart';
import 'banner_page.dart';

class BannerListPage extends StatelessWidget {
  const BannerListPage({super.key});

  // iOS 尺寸对照表（来自 PLAN.md §2.1 AndroidBannerConfig/IOSBannerConfig）
  static const _sizes = [
    _BannerSize(label: '300×45 (60×90)', width: 300, height: 45),
    _BannerSize(label: '320×50 (640×100)', width: 320, height: 50),
    _BannerSize(label: '300×75 (600×150)', width: 300, height: 75),
    _BannerSize(label: '345×194 (690×388)', width: 345, height: 194),
    _BannerSize(label: '300×130 (600×260)', width: 300, height: 130),
    _BannerSize(label: '300×150 (600×300)', width: 300, height: 150),
    _BannerSize(label: '300×200 (600×400)', width: 300, height: 200),
    _BannerSize(label: '300×250 (600×500)', width: 300, height: 250),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner 广告')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('模板 Banner（多尺寸）', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ..._sizes.map((s) => ListTile(
                title: Text('模板 Banner ${s.label}'),
                trailing: const Icon(Icons.navigate_next),
                onTap: () => context.navigateTo(BannerPage(
                  title: '模板 Banner ${s.label}',
                  width: s.width,
                  height: s.height,
                )),
              )),
          const Divider(),
          ListTile(
            title: const Text('原生 Banner'),
            subtitle: const Text('需要新 Plugin 接口（Phase 3 实现）'),
            trailing: const Icon(Icons.lock_outline),
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _BannerSize {
  final String label;
  final double width;
  final double height;

  const _BannerSize({required this.label, required this.width, required this.height});
}
