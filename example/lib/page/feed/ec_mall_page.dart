import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';

class EcMallPage extends StatefulWidget {
  const EcMallPage({super.key});

  @override
  State<EcMallPage> createState() => _EcMallPageState();
}

class _EcMallPageState extends State<EcMallPage> {
  String? _errorMsg;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final slotId = Platform.isIOS ? kIOSEcMallId : kAndroidEcMallId;

    return Scaffold(
      appBar: AppBar(title: const Text('电商 Mall')),
      body: Stack(
        children: [
          EcMallView(
            slotId: slotId,
            width: size.width,
            height: size.height,
            onShow: () => setState(() => _errorMsg = null),
            onClick: () => debugPrint('EcMall clicked'),
            onDislike: (option, enforce) =>
                debugPrint('EcMall dislike: $option'),
            onError: (code, message) =>
                setState(() => _errorMsg = '$code: $message'),
          ),
          if (_errorMsg != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
