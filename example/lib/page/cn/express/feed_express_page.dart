/*
 * Copyright (c) 2021 nullptrX
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../../widget/loading.dart';
import '../../common/empty_page.dart';
import '../constant.dart';
import '../../../common/common.dart';

class FeedExpressPage extends StatefulWidget {
  @override
  _FeedExpressPageState createState() => _FeedExpressPageState();
}

class Item {
  bool isAd;
  String id;
  final String feedId;

  Item({this.isAd = false, this.feedId = '', this.id = ''});
}

// class _ItemKey extends GlobalObjectKey<State> {
//   _ItemKey(Object value) : super(value);
// }

class _FeedExpressPageState extends State<FeedExpressPage> {
  final items = <Item>[];
  final feedIds = <String>[];
  final feedDialogIds = <String>[];

  final _bodyKey = GlobalKey();
  final _otherKey = GlobalKey();
  var _bgColor =
      kThemeStatus == PangleTheme.light ? Colors.white : Colors.black;

  Completer<BannerViewController> controller = Completer();

  @override
  void initState() {
    super.initState();
    _loadFeedAd();
  }

  @override
  void dispose() {
    _removeFeedAd();
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
          child: RefreshIndicator(
            onRefresh: () async {
              await _loadFeedAd();
            },
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildItem(index);
              },
            ),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        key: _otherKey,
        onPressed: () async {
          // await _loadFeedAd(isRefresh: false);
          _showFeedDialog();
        },
        child: Icon(Icons.get_app),
      ),
    );
  }

  Widget _buildItem(int index) {
    var item = items[index];
    if (item.isAd) {
      return Container(
        color: _bgColor,
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 375 / 284.0,
          child: FeedView(
            id: item.feedId,
            onFeedViewCreated: (controller) {
              _initConstraintBounds(controller);
            },
            onDislike: (option, enforce) {
              pangle.removeFeedAd([item.feedId]);
              setState(() {
                items.removeAt(index);
              });
            },
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          items.removeAt(index);
        });
      },
      child: Loading(),
    );
  }

  /// 加载广告
  _loadFeedAd({bool isRefresh = true}) async {
    // var expressSize = PangleExpressSize(width: 375, height: 284);
    var expressSize = PangleExpressSize.aspectRatio(375 / 284);
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
      if (isRefresh) {
        this.items
          ..clear()
          ..addAll(data);
      } else {
        this.items.addAll(data);
      }
    });
  }

  /// 移除广告
  _removeFeedAd() async {
    int? count = await pangle.removeFeedAd(feedIds);
    await pangle.removeFeedAd(feedDialogIds);
    print('Feed Ad Removed: $count');
  }

  _initConstraintBounds(FeedViewController controller) {
    if (!Platform.isIOS) {
      return;
    }

    RenderBox bodyBox =
        _bodyKey.currentContext!.findRenderObject() as RenderBox;
    final bodyBound = PangleHelper.fromRenderBox(bodyBox);
    controller.updateTouchableBounds([bodyBound]);

    RenderBox otherBox =
        _otherKey.currentContext!.findRenderObject() as RenderBox;
    final otherBound = PangleHelper.fromRenderBox(otherBox);

    controller.updateRestrictedBounds([otherBound]);
  }

  void _showFeedDialog() async {
    // Dialog默认insetPadding horizontal 40
    final maxWidth = MediaQuery.of(context).size.width;
    var width = maxWidth - 80;
    var height = width / (375 / 284);
    var expressSize = PangleExpressSize(
      width: width,
      height: height,
    );
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
    if (feedAd.count > 0) {
      if (feedDialogIds.isNotEmpty) {
        pangle.removeFeedAd(feedDialogIds);
      }
      feedDialogIds
        ..clear()
        ..addAll(feedAd.data);

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: AspectRatio(
              aspectRatio: 375 / 284,
              child: FeedView(
                id: feedDialogIds.first,
              ),
            ),
          );
        },
      );
    }
  }
}
