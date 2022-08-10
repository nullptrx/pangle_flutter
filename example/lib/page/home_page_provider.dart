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

import '../common/common.dart';
import '../common/version.dart';

mixin HomePageProviderStateMixin<T extends StatefulWidget> on State<T> {
  String? _denpendencies;
  PangleTheme _theme = PangleTheme.light;

  @override
  void initState() {
    super.initState();
    loadTheme();
    _initDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pangle Flutter Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                title: const Text('Testing environment:'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(kEnv),
                ),
              ),
              ListTile(
                title: const Text('Dependencies:'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_denpendencies ?? ''),
                ),
              ),
              ListTile(
                title: const Text('Theme: '),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('$_theme'),
                ),
              ),
              ElevatedButton(
                onPressed: requestPermissions,
                child: const Text('Request Permissions'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: openGDPRPrivacyOnIOS,
                child: const Text('GDPR Privacy For iOS'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: changeTheme,
                child: const Text('Change Theme'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadNativeAd,
                child: const Text('Native AD'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loadExpressAd,
                child: const Text('Express AD'),
              ),
              const SizedBox(height: 90),
            ],
          ),
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

  void loadTheme() async {
    var theme = await pangle.getThemeStatus();
    kThemeStatus = theme;
    setState(() {
      _theme = theme;
    });
  }

  void changeTheme() async {
    var theme = await pangle.getThemeStatus();
    var tmpTheme =
        theme == PangleTheme.light ? PangleTheme.dark : PangleTheme.light;
    var newTheme = await pangle.setThemeStatus(tmpTheme);

    kThemeStatus = newTheme;
    setState(() {
      _theme = newTheme;
    });
  }

  void requestPermissionsOnIOS() async {
    var status = await pangle.getTrackingAuthorizationStatus();
    debugPrint('trackingAuthorizationStatus: $status');
    if (status == PangleAuthorizationStatus.notDetermined) {
      status = await pangle.requestTrackingAuthorization();
      debugPrint('requestTrackingAuthorization: $status');
    }
  }

  void showPrivacyProtectionOnAndroid() async {
    await pangle.showPrivacyProtection();
  }

  void openGDPRPrivacyOnIOS() async {
    bool confirm = await pangle.openGDPRPrivacy();
    debugPrint('GDPR Privacy: $confirm');
  }

  void loadNativeAd();

  void loadExpressAd();
}
