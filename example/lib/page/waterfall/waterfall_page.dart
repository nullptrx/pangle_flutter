import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';

class WaterfallPage extends StatefulWidget {
  const WaterfallPage({super.key});

  @override
  State<WaterfallPage> createState() => _WaterfallPageState();
}

class _WaterfallPageState extends State<WaterfallPage> {
  final _widthCtrl = TextEditingController(text: '350');
  final _heightCtrl = TextEditingController(text: '0');

  final _feedIds = <String>[];
  bool _loading = false;
  String? _errorMsg;

  // 保存上次加载时使用的尺寸，供 FeedView 使用
  PangleExpressSize _expressSize = PangleExpressSize(width: 350, height: 0);

  @override
  void dispose() {
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    if (_feedIds.isNotEmpty) {
      pangle.removeFeedAd(_feedIds);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('瀑布流广告')),
      body: Column(
        children: [
          _buildInputArea(),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (_errorMsg != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(_errorMsg!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            )
          else if (_feedIds.isNotEmpty)
            Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _widthCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '宽度 (dp)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _heightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '高度 (dp，0=自适应)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('加载图文广告'),
              onPressed: _loading ? null : _loadAds,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: _feedIds.length,
      itemBuilder: (context, index) {
        return FeedView(
          id: _feedIds[index],
          expressSize: _expressSize,
          onDislike: (_, i) {
            pangle.removeFeedAd([_feedIds[index]]);
            setState(() => _feedIds.removeAt(index));
          },
        );
      },
    );
  }

  Future<void> _loadAds() async {
    final w = double.tryParse(_widthCtrl.text.trim()) ?? 350;
    final h = double.tryParse(_heightCtrl.text.trim()) ?? 0;
    final expressSize = PangleExpressSize(width: w, height: h);

    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    // 先释放上条广告
    if (_feedIds.isNotEmpty) {
      await pangle.removeFeedAd(_feedIds);
      _feedIds.clear();
    }

    try {
      final feedAd = await pangle.loadFeedAd(
        iOS: IOSFeedConfig(
          slotId: kIOSFeedExpressId,
          expressSize: expressSize,
          count: 3,
        ),
        android: AndroidFeedConfig(
          slotId: kAndroidFeedExpressId,
          expressSize: expressSize,
          count: 3,
          imgSize: PangleSize(width: w * 2, height: h > 0 ? h * 2 : w * 1.25),
        ),
      );
      if (mounted) {
        setState(() {
          _expressSize = expressSize;
          _feedIds.addAll(feedAd.data);
          if (feedAd.data.isEmpty) {
            _errorMsg = '未返回广告数据（code=${feedAd.code}）';
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
