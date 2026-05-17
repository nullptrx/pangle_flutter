import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';

class WaterfallPage extends StatefulWidget {
  const WaterfallPage({super.key});

  @override
  State<WaterfallPage> createState() => _WaterfallPageState();
}

class _WaterfallPageState extends State<WaterfallPage> {
  final _feedIds = <String>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  @override
  void dispose() {
    pangle.removeFeedAd(_feedIds);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('瀑布流广告')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAds,
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
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
                    expressSize: PangleExpressSize(width: 160, height: 0),
                    onDislike: (_, i) {
                      pangle.removeFeedAd([_feedIds[index]]);
                      setState(() => _feedIds.removeAt(index));
                    },
                  );
                },
              ),
            ),
    );
  }

  Future<void> _loadAds() async {
    setState(() => _loading = true);
    try {
      final expressSize = PangleExpressSize(width: 160, height: 0);
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
          imgSize: PangleSize(width: 640, height: 640),
        ),
      );
      if (mounted) {
        setState(() {
          _feedIds
            ..clear()
            ..addAll(feedAd.data);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }
}
