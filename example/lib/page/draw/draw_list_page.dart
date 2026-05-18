import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';

class DrawListPage extends StatefulWidget {
  const DrawListPage({super.key});

  @override
  State<DrawListPage> createState() => _DrawListPageState();
}

class _DrawListPageState extends State<DrawListPage> {
  final List<String> _adIds = [];
  bool _loading = false;
  String? _error;

  Future<void> _loadDrawAds() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await pangle.loadDrawAd(
        iOS: IOSDrawConfig(
          slotId: kIOSDrawExpressId,
          adCount: 2,
        ),
        android: AndroidDrawConfig(
          slotId: kAndroidDrawExpressId,
          adCount: 2,
        ),
      );
      if (!mounted) return;
      if (result.code == 0 && result.data.isNotEmpty) {
        setState(() => _adIds.addAll(result.data));
      } else {
        setState(() => _error = 'code=${result.code} ${result.message}');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    if (_adIds.isNotEmpty) {
      pangle.removeDrawAd(_adIds);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_adIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Draw 竖版视频广告')),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center),
                      ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('加载 Draw 广告'),
                      onPressed: _loadDrawAds,
                    ),
                  ],
                ),
        ),
      );
    }

    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _adIds.length,
        itemBuilder: (context, index) {
          return _DrawAdItem(
            adId: _adIds[index],
            onBack: index == 0 ? () => Navigator.pop(context) : null,
          );
        },
      ),
    );
  }
}

class _DrawAdItem extends StatelessWidget {
  const _DrawAdItem({required this.adId, this.onBack});

  final String adId;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DrawView(
          id: adId,
          gestureRecognizers: Platform.isAndroid ? null : null,
          onRenderSuccess: (w, h) {},
          onRenderFail: (code, msg) {
            debugPrint('DrawView render fail: $code $msg');
          },
        ),
        if (onBack != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack,
            ),
          ),
      ],
    );
  }
}
