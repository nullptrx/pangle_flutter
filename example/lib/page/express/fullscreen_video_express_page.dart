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

class FullscreenVideoExpressPage extends StatefulWidget {
  const FullscreenVideoExpressPage({Key? key}) : super(key: key);

  @override
  _FullscreenVideoExpressPageState createState() =>
      _FullscreenVideoExpressPageState();
}

class _FullscreenVideoExpressPageState
    extends State<FullscreenVideoExpressPage> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fullscreen Video AD'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: ElevatedButton(
              onPressed: _onTapLoad,
              child: const Text('Load'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _loaded ? _onTapShow : null,
              child: const Text('Show Ad'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: _onTapShowFullscreen,
              child: const Text('Show Fullscreen Ad'),
            ),
          ),
        ],
      ),
    );
  }

  _onTapLoad() async {
    final result = await pangle.loadFullscreenVideoAd(
      iOS: const IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preloadOnly,
      ),
      android: const AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.preloadOnly,
      ),
      callback: (event) {
        debugPrint('fullscreen: $event');
      },
    );
    var data = jsonEncode(result);
    debugPrint(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data)),
    );
    setState(() {
      _loaded = result.ok;
    });
  }

  _onTapShow() async {
    final result = await pangle.loadFullscreenVideoAd(
      iOS: const IOSFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.normal,
      ),
      android: const AndroidFullscreenVideoConfig(
        slotId: kFullscreenVideoExpressId,
        loadingType: PangleLoadingType.normal,
      ),
      callback: (event) {
        debugPrint('fullscreen: $event');
      },
    );
    var data = jsonEncode(result);
    debugPrint(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data)),
    );
    setState(() {
      _loaded = false;
    });
  }

  _onTapShowFullscreen() async {
    final result = await pangle.loadFullscreenVideoAd(
      iOS: const IOSFullscreenVideoConfig(
        slotId: kFullscreenIdFull,
      ),
      android: const AndroidFullscreenVideoConfig(
        slotId: kFullscreenIdFull,
      ),
      callback: (event) {
        debugPrint('fullscreen: $event');
      },
    );
    var data = jsonEncode(result);
    debugPrint(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(data)),
    );
  }
}
