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

import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:sprintf/sprintf.dart';

import '../common/version.dart';

mixin HomePageProviderStateMixin<T extends StatefulWidget> on State<T> {
  String? _denpendencies;
  int _theme = 0;

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
            ListTile(
              title: Text('Theme: '),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('$_theme'),
              ),
            ),
            ElevatedButton(
              onPressed: requestPermissions,
              child: Text('Request Permissions'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: changeTheme,
              child: Text('Change Theme'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: loadNativeAd,
              child: Text('Native AD'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: loadExpressAd,
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

  void requestPermissions();

  void requestPermissionsOnAndroid() async {
    // await [Permission.location, Permission.phone, Permission.storage].request();

    await pangle.requestPermissionIfNecessary();
  }

  void changeTheme() async {
    var theme = await pangle.getThemeStatus();
    var newTheme = theme == 0 ? 1 : 0;
    pangle.setThemeStatus(newTheme);
    setState(() {
      _theme = newTheme;
    });
  }

  void requestPermissionsOnIOS() async {
    var status = await pangle.getTrackingAuthorizationStatus();
    print('trackingAuthorizationStatus: $status');
    if (status == PangleAuthorizationStatus.notDetermined) {
      status = await pangle.requestTrackingAuthorization();
      print('requestTrackingAuthorization: $status');
    }
  }

  void showPrivacyProtectionOnAndroid() async {
    await pangle.showPrivacyProtection();
  }

  void loadNativeAd();

  void loadExpressAd();
}
