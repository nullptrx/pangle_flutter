import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/common/constant.dart';

class CustomSplashPage extends StatefulWidget {
  @override
  _CustomSplashPageState createState() => _CustomSplashPageState();
}

class _CustomSplashPageState extends State<CustomSplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Splash AD'),
      ),
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
                backgroundColor: Colors.black,
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
}
