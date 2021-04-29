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

class RewardedVideoExpressPage extends StatefulWidget {
  @override
  _RewardedVideoExpressPageState createState() =>
      _RewardedVideoExpressPageState();
}

class _RewardedVideoExpressPageState extends State<RewardedVideoExpressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewarded Video Express AD'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: _onTapLoad,
                child: Text('Load'),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _onTapShow,
                child: Text('Show ad'),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _onTapShowAndLoad,
                child: Text('Show ad and preload'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onTapLoad() async {
    final result = await pangle.loadRewardedVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload_only,
      ),
    );
    var data = jsonEncode(result);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data)),
    );
  }

  _onTapShow() async {
    final result = await pangle.loadRewardedVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.normal,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.normal,
      ),
    );
    var data = jsonEncode(result);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data)),
    );
  }

  _onTapShowAndLoad() async {
    final result = await pangle.loadRewardedVideoAd(
      iOS: IOSRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload,
      ),
      android: AndroidRewardedVideoConfig(
        slotId: kRewardedVideoExpressId,
        loadingType: PangleLoadingType.preload,
      ),
    );
    var data = jsonEncode(result);
    print(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data)),
    );
  }
}
