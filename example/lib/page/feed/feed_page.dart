import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../widget/loading.dart';
import '../constant.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _Item {
  final bool isAd;
  final String feedId;
  final String id;

  const _Item({this.isAd = false, this.feedId = '', this.id = ''});
}

class _FeedPageState extends State<FeedPage> {
  final _items = <_Item>[];
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadFeedAd();
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
              ElevatedButton(onPressed: _loadFeedAd, child: const Text('重试')),
            ],
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _loadFeedAd,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) => _buildItem(index),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('模板信息流广告')),
      body: body,
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    if (item.isAd) {
      return FeedView(
        id: item.feedId,
        expressSize: PangleExpressSize(width: 350, height: 0),
        onDislike: (_, i) => setState(() => _items.removeAt(index)),
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _items.removeAt(index)),
      child: const Loading(),
    );
  }

  Future<void> _loadFeedAd() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final expressSize = PangleExpressSize(width: 350, height: 0);
      final feedAd = await pangle.loadFeedAd(
        iOS: IOSFeedConfig(
          slotId: kIOSFeedExpressId,
          expressSize: expressSize,
        ),
        android: AndroidFeedConfig(
          slotId: kAndroidFeedExpressId,
          expressSize: expressSize,
          imgSize: PangleSize(width: 640, height: 320),
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
      debugPrint('FeedPage loadFeedAd error: $e');
      if (mounted) setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ─── iOS 信息流视频 ────────────────────────────────────────────────────────────

class FeedVideoPage extends StatefulWidget {
  const FeedVideoPage({super.key});

  @override
  State<FeedVideoPage> createState() => _FeedVideoPageState();
}

class _FeedVideoPageState extends State<FeedVideoPage> {
  final _items = <_Item>[];
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadFeedAd();
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
              ElevatedButton(onPressed: _loadFeedAd, child: const Text('重试')),
            ],
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _loadFeedAd,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) => _buildItem(index),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('模板信息流视频广告')),
      body: body,
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    if (item.isAd) {
      return FeedView(
        id: item.feedId,
        expressSize: PangleExpressSize.aspectRatio16_9(),
        onDislike: (_, i) => setState(() => _items.removeAt(index)),
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _items.removeAt(index)),
      child: const Loading(),
    );
  }

  Future<void> _loadFeedAd() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final expressSize = PangleExpressSize.aspectRatio16_9();
      final feedAd = await pangle.loadFeedAd(
        iOS: IOSFeedConfig(
          slotId: kIOSFeedVideoId,
          expressSize: expressSize,
        ),
        android: AndroidFeedConfig(
          slotId: kAndroidFeedVideoExpressId,
          expressSize: expressSize,
          imgSize: PangleSize(width: 640, height: 360),
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
      debugPrint('FeedVideoPage loadFeedAd error: $e');
      if (mounted) setState(() => _errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
