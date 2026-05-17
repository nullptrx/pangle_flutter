import 'package:flutter/material.dart';

class StreamPage extends StatelessWidget {
  const StreamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('流媒体自定义播放')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Stream 广告待实现',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '需要新 Plugin 接口 loadStreamAd()，返回视频 URL 后由 Flutter video_player 播放。\n'
                '将在 Phase 2（Dart 层��+ Phase 3（Android）+ Phase 4（iOS）中实现。',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
