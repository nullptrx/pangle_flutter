import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/page/common/empty_page.dart';

import '../../common/constant.dart';
import '../../widget/loading.dart';

class FeedExpressPage extends StatefulWidget {
  @override
  _FeedExpressPageState createState() => _FeedExpressPageState();
}

class Item {
  bool isAd;
  String id;
  String feedId;

  Item({this.isAd = false, this.feedId, this.id});
}

class _FeedExpressPageState extends State<FeedExpressPage> {
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
        title: Text('Feed Express AD'),
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => EmptyPage(),
            ));
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              title: Text('Like'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              title: Text('Dislike'),
            ),
          ]),
      body: Container(
          child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          if (item.isAd) {
            return Center(
              child: FeedView(
                id: item.feedId,
                isUserInteractionEnabled: false,
                onRemove: () {
                  setState(() {
                    this.items.removeAt(index);
                  });
                },
              ),
            );
          }

          return Loading();
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
        slotId: kFeedVideoExpressId,
        expressSize: PangleExpressSize.widthPercent(1.0, aspectRatio: 1.32),
        // slotId: kFeedId,
      ),
      android: AndroidFeedConfig(
        slotId: kFeedVideoExpressId,
        expressSize: PangleExpressSize.widthPercent(1.0, aspectRatio: 1.32),
        // slotId: kFeedId,
      ),
    );
    // PangleFeedAd feedAd = await pangle.loadFeedAd(
    //   iOS: IOSFeedConfig(
    //     slotId: kFeedTestExpressId,
    //     expressSize: PangleExpressSize.widthPercent(
    //       0.9,
    //       aspectRatio: 240.0 / 265.0,
    //     ),
    //     // slotId: kFeedId,
    //   ),
    //   android: AndroidFeedConfig(
    //     slotId: kFeedTestExpressId,
    //     expressSize: PangleExpressSize.widthPercent(
    //       0.9,
    //       aspectRatio: 240.0 / 265.0,
    //     ),
    //     // slotId: kFeedId,
    //   ),
    // );
    final data = <Item>[];
    int totalCount = 20;

    for (var i = 0; i < totalCount; i++) {
      var item = Item(id: i.toString());
      data.add(item);
    }

    final itemPositions = [5, 10, 15];
    for (var i = 0; i < feedAd.count; i++) {
      int index = itemPositions.removeAt(0);
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
