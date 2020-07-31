import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/common/constant.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class Item {
  bool isAd;

  Item({this.isAd = false});
}

class _FeedPageState extends State<FeedPage> {
  final items = <Item>[];

  @override
  void initState() {
    super.initState();
    _loadFeedAd();
  }

  _loadFeedAd() async {
    int count = await pangle.loadFeedAd(
      iOS: IOSFeedAdConfig(slotId: kFeedId, count: 2),
      android: AndroidFeedAdConfig(slotId: kFeedId, count: 2),
    );
    final data = <Item>[];
    int totalCount = 20;

    var item;
    for (var i = 0; i < totalCount; i++) {
      item = Item();
      data.add(item);
    }

    for (var i = 0; i < count; i++) {
      int index = Random().nextInt(totalCount);
      final item = Item(isAd: true);
      data.insert(index, item);
    }
    setState(() {
      this.items.addAll(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed Ad'),
      ),
      body: Container(
          child: ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          if (item.isAd) {
            return FeedView();
          }

          return Container(
            height: 50,
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: Text('item $index'),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            indent: 0.0,
            endIndent: 0.0,
          );
        },
      )),
    );
  }
}
