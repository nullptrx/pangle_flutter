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

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';

class BannerExpressPage extends StatefulWidget {
  @override
  _BannerExpressPageState createState() => _BannerExpressPageState();
}

class _BannerExpressPageState extends State<BannerExpressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banner Express AD'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 600 / 260.0,
              child: BannerView(
                // key: _banner1Key,
                iOS: IOSBannerConfig(
                  slotId: kBannerExpressId600x260,
                  expressSize: PangleExpressSize(width: 600, height: 260),
                ),
                android: AndroidBannerConfig(
                  slotId: kBannerExpressId600x260,
                  expressSize: PangleExpressSize(width: 600, height: 260),
                ),
              ),
            ),
            Container(
              height: 260,
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
                  controller.updateTouchableBounds([Rect.zero]);
                  controller.updateRestrictedBounds([Rect.zero]);
                },
                onClick: () {},
              ),
            ),
            SizedBox(height: 1080),
            Center(child: Text('--- 这是底线 ---')),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
