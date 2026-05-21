import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../page/constant.dart';
import 'home_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  bool _useMediation = false;
  bool _loading = false;
  String? _error;

  Future<void> _initialize() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ret = await pangle.init(
        iOS: IOSConfig(
          appId: kIOSAppId,
          logLevel: PangleLogLevel.debug,
          useMediation: _useMediation,
        ),
        android: AndroidConfig(
          appId: kAndroidAppId,
          debug: true,
          allowShowNotify: true,
          useTextureView: true,
          directDownloadNetworkType: [AndroidDirectDownloadNetworkType.k2G],
          useMediation: _useMediation,
        ),
      );
      debugPrint('pangle init: $ret');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SDK 初始化配置')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('SDK 模式', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
          ),
          RadioListTile<bool>(
            title: const Text('聚合模式'),
            subtitle: const Text('useMediation = true，初始化 CSJMediation 聚合组件'),
            value: true,
            groupValue: _useMediation,
            onChanged: _loading ? null : (v) => setState(() => _useMediation = v!),
          ),
          RadioListTile<bool>(
            title: const Text('非聚合模式'),
            subtitle: const Text('useMediation = false，仅使用穿山甲自有广告'),
            value: false,
            groupValue: _useMediation,
            onChanged: _loading ? null : (v) => setState(() => _useMediation = v!),
          ),
          const Divider(height: 1),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _initialize,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('初始化 SDK'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
