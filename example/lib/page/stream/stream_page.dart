import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

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
        title: const Text('流媒体自定义播放'),
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
          label: const Text('加载 Stream 广告'),
          onPressed: _loadStreamAds,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _items.length,
      separatorBuilder: (_, i) => const Divider(),
      itemBuilder: (context, index) => _StreamAdTile(item: _items[index]),
    );
  }
}

class _StreamAdTile extends StatelessWidget {
  const _StreamAdTile({required this.item});
  final StreamAdItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.title != null)
            Text(item.title!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          if (item.description != null) ...[
            const SizedBox(height: 4),
            Text(item.description!,
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
          ],
          const SizedBox(height: 8),
          _InfoRow(label: 'imageMode', value: item.imageMode.toString()),
          if (item.videoDuration > 0)
            _InfoRow(
                label: 'duration',
                value: '${item.videoDuration.toStringAsFixed(1)}s'),
          if (item.videoUrl != null)
            _InfoRow(label: 'videoUrl', value: item.videoUrl!),
          if (item.imageUrl != null)
            _InfoRow(label: 'imageUrl', value: item.imageUrl!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text('$label:',
                style:
                    const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 2),
          ),
        ],
      ),
    );
  }
}
