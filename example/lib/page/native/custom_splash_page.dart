import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/common/constant.dart';
import 'package:pangle_flutter_example/common/ext.dart';
import 'package:pangle_flutter_example/page/home_page.dart';

class CustomSplashPage extends StatefulWidget {
  final bool isRoot;

  const CustomSplashPage({Key key, this.isRoot = true}) : super(key: key);

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
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: SplashView(
              iOS: IOSSplashConfig(
                slotId: kSplashId,
                isExpress: false,
                tolerateTimeout: 3,
              ),
              android: AndroidSplashConfig(
                slotId: kSplashId,
                isExpress: false,
                tolerateTimeout: 3,
              ),
              onShow: _handleAdStart,
              onTimeOver: _handleAdEnd,
              onClick: _handleAdEnd,
              onSkip: _handleAdEnd,
              onError: (code, message) => _handleAdEnd(),
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
    );
  }

  _handleAdStart() {}

  _handleAdEnd() {
    SystemChrome.setEnabledSystemUIOverlays([
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);
    Navigator.of(context).pop();
    if (widget.isRoot) {
      context.navigateTo(HomePage());
    }
  }
}
