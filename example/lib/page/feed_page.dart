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
  String id;
  String feedId;

  Item({this.isAd = false, this.feedId, this.id});
}

class _FeedPageState extends State<FeedPage> {
  final items = <Item>[];

  @override
  void initState() {
    super.initState();
    _loadFeedAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed AD'),
      ),
      body: Container(
          child: ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          if (item.isAd) {
            return FeedView(
              id: item.feedId,
              isExpress: false,
              onRemove: () {
                setState(() {
                  this.items.removeAt(index);
                });
              },
            );
          }

          return Container(
            height: 50,
            alignment: Alignment.center,
            padding: EdgeInsets.all(8),
            child: Text('item ${item.id}'),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            indent: 0.0,
            endIndent: 0.0,
          );
        },
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _loadFeedAd();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  /// 加载广告
  _loadFeedAd() async {
    PangleFeedAd feedAd = await pangle.loadFeedAd(
      iOS: IOSFeedConfig(
        slotId: kFeedId,
        isExpress: false,
        imgSize: PangleImgSize.feed228_150,
        // slotId: kFeedId,
        count: 3,
      ),
      android: AndroidFeedConfig(
        slotId: kFeedId,
        isExpress: false,
        imgSize: PangleImgSize.feed228_150,
        // slotId: kFeedId,
        count: 3,
      ),
    );
    final data = <Item>[];
    int totalCount = 20;

    var item;
    for (var i = 0; i < totalCount; i++) {
      item = Item(id: i.toString());
      data.add(item);
    }

    for (var i = 0; i < feedAd.count; i++) {
      int index = Random().nextInt(totalCount);
      final item = Item(isAd: true, feedId: feedAd.data[i]);
      data.insert(index, item);
    }
    setState(() {
      this.items
        ..clear()
        ..addAll(data);
    });
  }
}
