import 'dart:async';
import 'dart:io';

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

// class _ItemKey extends GlobalObjectKey<State> {
//   _ItemKey(Object value) : super(value);
// }

class _FeedExpressPageState extends State<FeedExpressPage> {
  final items = <Item>[];
  final feedIds = <String>[];

  final _bodyKey = GlobalKey();
  final _otherKey = GlobalKey();

  Completer<BannerViewController> controller = Completer();

  @override
  void initState() {
    super.initState();
    _loadFeedAd();
  }

  @override
  void dispose() {
    super.dispose();
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
              label: 'Like',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Dislike',
            ),
          ]),
      body: Container(
          key: _bodyKey,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildItem(index);
            },
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        key: _otherKey,
        onPressed: () {
          _loadFeedAd();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildItem(int index) {
    var item = items[index];
    if (item.isAd) {
      return AspectRatio(
        aspectRatio: 375 / 284.0,
        child: FeedView(
          // key: _ItemKey(item.feedId),
          id: item.feedId,
          onFeedViewCreated: (controller) {
            _initConstraintBounds(controller);
          },
          // isUserInteractionEnabled: false,
          // onRemove: () {
          //   this.feedIds.remove(item.feedId);
          //   setState(() {
          //     this.items.removeAt(index);
          //   });
          // },
        ),
      );
    }

    return Loading();
  }

  /// 加载广告
  _loadFeedAd() async {
    var expressSize = PangleExpressSize(width: 375, height: 284);
    PangleAd feedAd = await pangle.loadFeedAd(
      iOS: IOSFeedConfig(
        slotId: kFeedExpressId375x284,
        expressSize: expressSize,
        // slotId: kFeedId,
      ),
      android: AndroidFeedConfig(
        slotId: kFeedExpressId375x284,
        expressSize: expressSize,
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

      feedIds.add(item.feedId);
    }
    setState(() {
      this.items..addAll(data);
    });
  }

  _initConstraintBounds(FeedViewController controller) {
    if (!Platform.isIOS) {
      return;
    }

    RenderBox bodyBox = _bodyKey.currentContext.findRenderObject();
    final bodyBound = PangleHelper.fromRenderBox(bodyBox);
    controller.updateTouchableBounds([bodyBound]);

    RenderBox otherBox = _otherKey.currentContext.findRenderObject();
    final otherBound = PangleHelper.fromRenderBox(otherBox);

    controller.updateRestrictedBounds([otherBound]);
  }
}
