import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:sprintf/sprintf.dart';

import '../common/ext.dart';
import 'home/express_page.dart';
import 'home/native_page.dart';

const kEnv = '''
Android Studio 4.1
Xcode 12.0.1

Flutter 1.22.1
Dart 2.10.1
Kotlin 1.4.10
Swift 5.2.4 
''';
const kDependencies = '''
Pangle SDK V%s
''';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _denpendencies;

  @override
  void initState() {
    super.initState();
    _initDependencies();
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
            ListTile(
              title: Text('Environment:'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(kEnv),
              ),
            ),
            ListTile(
              title: Text('Dependencies:'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_denpendencies ?? ''),
              ),
            ),
            RaisedButton(
              onPressed: _requestPermissions,
              child: Text('Request Permissions'),
            ),
            SizedBox(height: 30),
            RaisedButton(
              onPressed: _loadNativeAd,
              child: Text('Native AD'),
            ),
            SizedBox(height: 30),
            RaisedButton(
              onPressed: _loadExpressAd,
              child: Text('Express AD'),
            ),
          ],
        ),
      ),
    );
  }

  void _initDependencies() async {
    final sdkVersion = await pangle.getSdkVersion();
    final text = sprintf(kDependencies, [sdkVersion]).toString();
    setState(() {
      _denpendencies = text;
    });
  }

  void _requestPermissions() async {
    if (Platform.isIOS) {
      _requestPermissionsIOS();
    } else {
      _requestPermissionsAndroid();
    }
  }

  void _requestPermissionsAndroid() async {
    // await [Permission.location, Permission.phone, Permission.storage].request();

    await pangle.requestPermissionIfNecessary();
  }

  void _requestPermissionsIOS() async {
    var status = await pangle.getTrackingAuthorizationStatus();
    print('trackingAuthorizationStatus: $status');
    if (status == PangleAuthorizationStatus.notDetermined) {
      status = await pangle.requestTrackingAuthorization();
      print('requestTrackingAuthorization: $status');
    }
  }

  void _loadNativeAd() {
    context.navigateTo(NativePage());
  }

  void _loadExpressAd() {
    context.navigateTo(ExpressPage());
  }
}
