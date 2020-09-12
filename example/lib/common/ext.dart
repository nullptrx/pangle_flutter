import 'package:flutter/cupertino.dart';

extension Navi on BuildContext {
  Future<dynamic> navigateTo(Widget child) {
    return Navigator.push(
      this,
      CupertinoPageRoute(builder: (context) => child),
    );
  }
}
