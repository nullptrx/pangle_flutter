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

class FullscreenVideoPage extends StatefulWidget {
  const FullscreenVideoPage({super.key});

  @override
  State<FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<FullscreenVideoPage> {
  FullscreenAd? _loadedAd;
  String _status = '未加载';

  @override
  void initState() {
    super.initState();
    // 应用启动时配置 Pool，自动预加载
    FullscreenAdPool.instance.configure(
      slotId: kFullscreenVideoExpressId,
      poolSize: 1,
      iOS: const IOSFullscreenVideoConfig(slotId: kFullscreenVideoExpressId),
      android:
          const AndroidFullscreenVideoConfig(slotId: kFullscreenVideoExpressId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fullscreen Video AD')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text('状态：$_status', style: Theme.of(context).textTheme.bodyMedium),
          const Divider(),
          // ── 新 API ────────────────────────────────────────────
          Text('新 API（加载/展示分离）',
              style: Theme.of(context).textTheme.titleSmall),
          ElevatedButton(
            onPressed: _onLoad,
            child: const Text('① 加载广告'),
          ),
          ElevatedButton(
            onPressed: _loadedAd?.isLoaded == true ? _onShow : null,
            child: const Text('② 展示广告（需先加载）'),
          ),
          const Divider(),
          // ── Pool 预加载 ────────────────────────────────────────
          Text('Pool 预加载展示',
              style: Theme.of(context).textTheme.titleSmall),
          ElevatedButton(
            onPressed: _onPoolShow,
            child: const Text('Pool 展示（自动补充）'),
          ),
        ],
      ),
    );
  }

  // ── 新 API：只加载，不展示 ──────────────────────────────────────────────

  Future<void> _onLoad() async {
    setState(() => _status = '加载中...');
    try {
      final ad = await FullscreenAd.load(
        slotId: kFullscreenVideoExpressId,
        iOS: const IOSFullscreenVideoConfig(slotId: kFullscreenVideoExpressId),
        android: const AndroidFullscreenVideoConfig(
            slotId: kFullscreenVideoExpressId),
      );
      setState(() {
        _loadedAd = ad;
        _status = '加载成功，可以展示';
      });
    } on AdLoadException catch (e) {
      setState(() => _status = '加载失败：$e');
    }
  }

  // ── 新 API：展示已加载的广告 ────────────────────────────────────────────

  Future<void> _onShow() async {
    final ad = _loadedAd;
    if (ad == null || !ad.isLoaded) return;

    setState(() => _status = '展示中...');
    try {
      await ad.show(
        onEvent: (event) {
          switch (event) {
            case AdClosedEvent():
              debugPrint('广告已关闭');
            case AdErrorEvent():
              debugPrint('广告出错');
            default:
              debugPrint('事件：$event');
          }
        },
      );
      setState(() {
        _loadedAd = null;
        _status = '展示完毕';
      });
    } catch (e) {
      setState(() => _status = '展示失败：$e');
    }
  }

  // ── Pool：直接展示，内部自动从缓存取 ───────────────────────────────────

  Future<void> _onPoolShow() async {
    final ready =
        await FullscreenAdPool.instance.isReady(kFullscreenVideoExpressId);
    if (!ready) {
      _showSnack('广告还没准备好，请稍后再试');
      return;
    }
    setState(() => _status = '展示中（Pool）...');
    final result = await FullscreenAdPool.instance.show(
      slotId: kFullscreenVideoExpressId,
      onEvent: (event) {
        debugPrint('fullscreen event: $event');
      },
    );
    setState(() => _status = result != null ? '展示完毕' : '展示失败（缓存为空）');
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
