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
  bool _showAd = false;

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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            child: Column(
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
                    backgroundColor: Colors.white,
                    onStateChanged: (state) {
                      switch (state) {
                        case SplashState.show:
                          _handleAdStart();
                          break;

                        case SplashState.timeOver:
                        case SplashState.click:
                        case SplashState.skip:
                          _handleAdEnd();
                          break;
                      }
                    },
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
          ),
          Offstage(
            offstage: _showAd,
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: FlutterLogo(size: 100),
            ),
          ),
        ],
      ),
    );
  }

  _handleAdStart() {
    setState(() {
      _showAd = true;
    });
  }

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
