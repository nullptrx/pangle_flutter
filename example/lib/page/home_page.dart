import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

import '../common/ext.dart';
import 'home/express_page.dart';
import 'home/native_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pangle Flutter Examples'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RaisedButton(
              onPressed: _requestPermissions,
              child: Text('Request Permissions'),
            ),
            RaisedButton(
              onPressed: _loadNativeAd,
              child: Text('Native AD'),
            ),
            RaisedButton(
              onPressed: _loadExpressAd,
              child: Text('Express AD'),
            ),
          ],
        ),
      ),
    );
  }

  void _requestPermissions() async {
//    pangle.requestPermissionIfNecessary();

    await [Permission.location, Permission.phone, Permission.storage].request();
  }

  void _loadNativeAd() {
    context.navigateTo(NativePage());
  }

  void _loadExpressAd() {
    context.navigateTo(ExpressPage());
  }
}
