import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';
import '../../widget/loading.dart';

class FeedIconPage extends StatefulWidget {
  const FeedIconPage({super.key});

  @override
  State<FeedIconPage> createState() => _FeedIconPageState();
}

class _FeedIconPageState extends State<FeedIconPage> {
  final _items = <_Item>[];
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadFeedIconAd();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_errorMsg != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMsg!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadFeedIconAd, child: const Text('重试')),
            ],
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _loadFeedIconAd,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) => _buildItem(index),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('模板信息流图标广告')),
      body: body,
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    if (item.isAd) {
      return FeedView(
        id: item.feedId,
        expressSize: PangleExpressSize(width: 160, height: 0),
        onDislike: (_, i) => setState(() => _items.removeAt(index)),
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _items.removeAt(index)),
      child: const Loading(),
    );
  }

  Future<void> _loadFeedIconAd() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final expressSize = PangleExpressSize(width: 160, height: 0);
      final feedAd = await pangle.loadFeedIconAd(
        iOS: IOSFeedConfig(
          slotId: kIOSFeedNativeId,
          expressSize: PangleExpressSize(width: 100, height: 100),
        ),
        android: AndroidFeedIconConfig(
          slotId: kAndroidFeedExpressId,
          adCount: 2,
          expressViewWidth: expressSize.width,
        ),
      );
      final data = <_Item>[];
      for (var i = 0; i < 20; i++) {
        data.add(_Item(id: i.toString()));
      }
      final positions = [5, 10, 15];
      for (var i = 0; i < feedAd.count && i < positions.length; i++) {
        data.insert(positions[i], _Item(isAd: true, feedId: feedAd.data[i]));
      }
      if (mounted) {
        setState(() => _items
          ..clear()
          ..addAll(data));
      }
    } catch (e) {
      debugPrint('FeedIconPage loadFeedIconAd error: $e');
      if (mounted) setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _Item {
  final bool isAd;
  final String feedId;
  final String id;

  const _Item({this.isAd = false, this.feedId = '', this.id = ''});
}
