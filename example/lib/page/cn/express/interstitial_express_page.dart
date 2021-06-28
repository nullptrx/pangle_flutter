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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';

class InterstitialExpressPage extends StatefulWidget {
  @override
  _InterstitialExpressPageState createState() =>
      _InterstitialExpressPageState();
}

class _InterstitialExpressPageState extends State<InterstitialExpressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interstitial Express AD'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: _onTapShow,
                child: Text('Show Ad'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapShow() async {
    final width = kPangleScreenWidth - 30;
    final height = width / 1.667;

    final result = await pangle.loadInterstitialAd(
      iOS: IOSInterstitialConfig(
        slotId: kInterstitialExpressId3x2,
        // 该宽高为你申请的广告位宽高，请根据实际情况赋值
        expressSize: PangleExpressSize(width: width, height: height),
      ),
      android: AndroidInterstitialConfig(
        slotId: kInterstitialExpressId3x2,
        // 该宽高为你申请的广告位宽高，请根据实际情况赋值
        expressSize: PangleExpressSize.widthPercent(0.8, aspectRatio: 1.667),
      ),
    );
    var data = jsonEncode(result);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data)),
    );
  }
}
