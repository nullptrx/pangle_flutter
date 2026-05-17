import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:video_player/video_player.dart';

import '../constant.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  List<StreamAdItem> _items = [];
  bool _loading = false;
  String? _error;

  Future<void> _loadStreamAds() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await pangle.loadStreamAd(
        iOS: IOSStreamConfig(slotId: kIOSStreamId),
        android: AndroidStreamConfig(slotId: kAndroidStreamId),
      );
      if (!mounted) return;
      if (result.code == 0 && result.data.isNotEmpty) {
        setState(() => _items = result.data);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('贴片广告'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadStreamAds,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadStreamAds, child: const Text('重试')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_outline),
          label: const Text('加载贴片广告'),
          onPressed: _loadStreamAds,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _items.length,
      separatorBuilder: (_, i) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _StreamAdTile(item: _items[index]),
    );
  }
}

class _StreamAdTile extends StatefulWidget {
  const _StreamAdTile({required this.item});
  final StreamAdItem item;

  @override
  State<_StreamAdTile> createState() => _StreamAdTileState();
}

class _StreamAdTileState extends State<_StreamAdTile> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _initializing = false;
  String? _initError;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    final url = widget.item.videoUrl;
    if (url == null || url.isEmpty) return;
    setState(() {
      _initializing = true;
      _initError = null;
    });
    try {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }
      setState(() {
        _controller = ctrl;
        _initialized = true;
        _initializing = false;
      });
      ctrl.play();
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _initError = e.toString();
        });
      }
    }
  }

  void _togglePlayback() {
    final ctrl = _controller;
    if (ctrl == null) return;
    setState(() {
      ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoArea(),
          if (widget.item.title != null || widget.item.description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.item.title != null)
                    Text(widget.item.title!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  if (widget.item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(widget.item.description!,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 12)),
                  ],
                ],
              ),
            ),
          if (widget.item.videoDuration > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                '时长：${widget.item.videoDuration.toStringAsFixed(1)}s',
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_initialized && _controller != null) {
      return _buildPlayer();
    }

    // 封面图 + 播放按钮浮层
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.item.imageUrl != null)
            Image.network(
              widget.item.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) =>
                  Container(color: Colors.black12),
            )
          else
            Container(color: Colors.black12),
          if (_initializing)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_initError != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 32),
                  const SizedBox(height: 4),
                  Text('播放失败',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 12)),
                ],
              ),
            )
          else if (widget.item.videoUrl != null)
            Center(
              child: GestureDetector(
                onTap: _initPlayer,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 36),
                ),
              ),
            )
          else
            const Center(
              child: Text('无视频 URL',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    final ctrl = _controller!;
    return AspectRatio(
      aspectRatio: ctrl.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(ctrl),
          VideoProgressIndicator(ctrl, allowScrubbing: true),
          Positioned(
            bottom: 20,
            right: 8,
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: ctrl,
              builder: (context2, value, child) => GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
