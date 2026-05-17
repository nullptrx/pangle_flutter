import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../constant.dart';

class NativeBannerPage extends StatelessWidget {
  const NativeBannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final slotId =
        Platform.isIOS ? kIOSBannerNativeId : kAndroidNativeBannerId;

    return Scaffold(
      appBar: AppBar(title: const Text('原生 Banner')),
      body: Center(
        child: SizedBox(
          width: 350,
          height: 300,
          child: NativeBannerView(
            slotId: slotId,
            width: 350,
            height: 300,
            onShow: () => debugPrint('NativeBanner onShow'),
            onClick: () => debugPrint('NativeBanner onClick'),
            onError: (code, msg) =>
                debugPrint('NativeBanner onError $code: $msg'),
            onDislike: (option, enforce) =>
                debugPrint('NativeBanner onDislike: $option enforce=$enforce'),
          ),
        ),
      ),
    );
  }
}
