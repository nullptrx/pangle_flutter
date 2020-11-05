import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/common/constant.dart';

class CustomSplashPage extends StatefulWidget {
  @override
  _CustomSplashPageState createState() => _CustomSplashPageState();
}

class _CustomSplashPageState extends State<CustomSplashPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SplashView(
                iOS: IOSSplashConfig(
                  slotId: kSplashId,
                  isExpress: false,
                ),
                android: AndroidSplashConfig(
                  slotId: kSplashId,
                  isExpress: false,
                ),
                backgroundColor: Colors.white,
                onTimeOver: _handleAd,
                onTimeout: _handleAd,
                onSkip: _handleAd,
                onClick: _handleAd,
                onError: (code, message) => _handleAd(),
              ),
            ),
            Container(
              alignment: Alignment.center,
              color: Colors.white,
              height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlutterLogo(size: 40),
                  SizedBox(height: 10),
                  Text('Pangle Flutter'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _handleAd() {
    Navigator.of(context).pop();
  }
}
