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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import '../../../common/ext.dart';
import '../constant.dart';
import '../home_page.dart';

class CustomSplashPage extends StatefulWidget {
  final bool isRoot;

  const CustomSplashPage({Key? key, this.isRoot = true}) : super(key: key);

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FlutterLogo(size: 40),
                SizedBox(width: 20),
                Text(
                  'Pangle Flutter',
                  style: GoogleFonts.zcoolQingKeHuangYou(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
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
