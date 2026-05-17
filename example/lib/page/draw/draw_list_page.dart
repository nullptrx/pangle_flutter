import 'package:flutter/material.dart';

class DrawListPage extends StatelessWidget {
  const DrawListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draw 竖版视频广告')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_library_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Draw 广告待实现',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '需要新 Plugin 接口 loadDrawAd() 和 DrawView Widget。\n'
                '将在 Phase 2（Dart 层）+ Phase 3（Android）+ Phase 4（iOS）中实现。',
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
