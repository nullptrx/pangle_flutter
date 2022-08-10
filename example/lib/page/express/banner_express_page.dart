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

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/common/version.dart';

import '../../../common/common.dart';
import '../constant.dart';
import '../empty_page.dart';

class BannerExpressPage extends StatefulWidget {
  const BannerExpressPage({Key? key}) : super(key: key);

  @override
  _BannerExpressPageState createState() => _BannerExpressPageState();
}

class _BannerExpressPageState extends State<BannerExpressPage> {
  final _bgColor =
      kThemeStatus == PangleTheme.light ? Colors.white : Colors.black;
  final rows = <Widget>[];

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      BannerView.platform = AndroidBannerView(
        useHybridComposition: isAndroidAbove10,
      );
    }
    initBanner();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Express AD'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.of(context).push(CupertinoPageRoute(
            builder: (context) => const EmptyPage(),
          ));
        },
        child: const Icon(Icons.get_app),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: rows,
          ),
        ),
      ),
    );
  }

  initBanner() {
    rows.clear();
    rows.addAll(<Widget>[
      AspectRatio(
        key: const BannerExpressKey(1),
        aspectRatio: 600 / 260.0,
        child: Container(
          color: _bgColor,
          child: BannerView(
            iOS: IOSBannerConfig(
              slotId: kBannerExpressId600x260,
              expressSize: PangleExpressSize(width: 600, height: 260),
            ),
            android: AndroidBannerConfig(
              slotId: kBannerExpressId600x260,
              expressSize: PangleExpressSize(width: 600, height: 260),
            ),
            onDislike: (message, enforce) {
              setState(() {
                rows.removeWhere((element) =>
                    (element.key as BannerExpressKey?)?.value == 1);
              });
            },
          ),
        ),
      ),
      Container(
        key: const BannerExpressKey(2),
        color: _bgColor,
        height: kPangleScreenWidth * 260 / 600,
        child: BannerView(
          iOS: IOSBannerConfig(
            slotId: kBannerExpressId600x260,
            expressSize: PangleExpressSize(width: 600, height: 260),
          ),
          android: AndroidBannerConfig(
            slotId: kBannerExpressId600x260,
            expressSize: PangleExpressSize(width: 600, height: 260),
          ),
          onBannerViewCreated: (BannerViewController controller) {
            controller.updateTouchableBounds([]);
            // controller.updateTouchableBounds([Rect.zero]);
            // controller.updateRestrictedBounds([Rect.zero]);
          },
          onDislike: (message, enforce) {
            setState(() {
              rows.removeWhere(
                  (element) => (element.key as BannerExpressKey?)?.value == 2);
            });
          },
          onError: (code, message) {
            debugPrint('BannerView: $code, $message');
          },
          onClick: () {},
        ),
      ),
      const SizedBox(height: 1080),
      const Center(
          child: Text(
        '--- 这是底线 ---',
        style: TextStyle(color: Colors.black),
      )),
      const SizedBox(height: 16),
    ]);
  }
}

class BannerExpressKey extends GlobalObjectKey {
  const BannerExpressKey(Object value) : super(value);
}
