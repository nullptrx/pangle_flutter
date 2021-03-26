/*
 * Copyright (c) 2021 nullptrX
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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
Android Studio 4.1.2
Xcode 12.4

Flutter 2.0.1
Dart 2.12.0
Kotlin 1.4.21
Swift 5.3.0
''';
const kDependencies = '''
Pangle SDK V%s
''';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _denpendencies;

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
            ElevatedButton(
              onPressed: _requestPermissions,
              child: Text('Request Permissions'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loadNativeAd,
              child: Text('Native AD'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
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
