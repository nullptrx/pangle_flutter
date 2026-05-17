import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

class RewardPage extends StatefulWidget {
  final String title;
  final String androidSlotId;
  final String iosSlotId;
  final bool isVertical;

  const RewardPage({
    super.key,
    required this.title,
    required this.androidSlotId,
    required this.iosSlotId,
    this.isVertical = true,
  });

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  RewardedAd? _loadedAd;
  String _status = '未加载';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('状态：$_status'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _onLoad,
              child: const Text('① 加载广告'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadedAd?.isLoaded == true ? _onShow : null,
              child: const Text('② 展示广告（需先加载）'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onLoad() async {
    setState(() => _status = '加载中...');
    try {
      final ad = await RewardedAd.load(
        slotId: widget.androidSlotId,
        iOS: IOSRewardedVideoConfig(slotId: widget.iosSlotId),
        android: AndroidRewardedVideoConfig(
          slotId: widget.androidSlotId,
          isVertical: widget.isVertical,
        ),
      );
      setState(() {
        _loadedAd = ad;
        _status = '加载成功，可以展示';
      });
    } on AdLoadException catch (e) {
      setState(() => _status = '加载失败：$e');
    }
  }

  Future<void> _onShow() async {
    final ad = _loadedAd;
    if (ad == null || !ad.isLoaded) return;
    setState(() => _status = '展示中...');
    try {
      final result = await ad.show(
        onEvent: (event) {
          if (event case AdRewardEvent(:final verified) when verified) {
            debugPrint('奖励验证：$verified');
          }
        },
      );
      setState(() {
        _loadedAd = null;
        _status = '展示完毕，verify=${result.isVerify}';
      });
    } catch (e) {
      setState(() => _status = '展示失败：$e');
    }
  }
}
