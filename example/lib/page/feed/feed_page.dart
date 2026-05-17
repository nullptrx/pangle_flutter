import 'dart:io';

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
  final _feedIds = <String>[];

  @override
  void initState() {
    super.initState();
    _loadFeedAd();
  }

  @override
  void dispose() {
    pangle.removeFeedAd(_feedIds);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模板信息流广告')),
      body: RefreshIndicator(
        onRefresh: _loadFeedAd,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) => _buildItem(index),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    if (item.isAd) {
      return FeedView(
        id: item.feedId,
        expressSize: PangleExpressSize(width: 350, height: 0),
        onDislike: (_, i) {
          pangle.removeFeedAd([item.feedId]);
          setState(() => _items.removeAt(index));
        },
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _items.removeAt(index)),
      child: const Loading(),
    );
  }

  Future<void> _loadFeedAd() async {
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
    for (var i = 0; i < feedAd.count; i++) {
      final pos = positions.removeAt(0);
      final adItem = _Item(isAd: true, feedId: feedAd.data[i]);
      data.insert(pos, adItem);
      _feedIds.add(adItem.feedId);
    }
    setState(() {
      _items
        ..clear()
        ..addAll(data);
    });
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
  final _feedIds = <String>[];

  @override
  void initState() {
    super.initState();
    _loadFeedAd();
  }

  @override
  void dispose() {
    pangle.removeFeedAd(_feedIds);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模板信息流视频广告')),
      body: RefreshIndicator(
        onRefresh: _loadFeedAd,
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) => _buildItem(index),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    if (item.isAd) {
      return FeedView(
        id: item.feedId,
        expressSize: PangleExpressSize.aspectRatio16_9(),
        onDislike: (_, i) {
          pangle.removeFeedAd([item.feedId]);
          setState(() => _items.removeAt(index));
        },
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _items.removeAt(index)),
      child: const Loading(),
    );
  }

  Future<void> _loadFeedAd() async {
    final expressSize = PangleExpressSize.aspectRatio16_9();
    final iosSlotId = Platform.isIOS ? kIOSFeedVideoId : kIOSFeedExpressId;
    final feedAd = await pangle.loadFeedAd(
      iOS: IOSFeedConfig(
        slotId: iosSlotId,
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
    for (var i = 0; i < feedAd.count; i++) {
      final pos = positions.removeAt(0);
      final adItem = _Item(isAd: true, feedId: feedAd.data[i]);
      data.insert(pos, adItem);
      _feedIds.add(adItem.feedId);
    }
    setState(() {
      _items
        ..clear()
        ..addAll(data);
    });
  }
}
