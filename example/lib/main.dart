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

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';

import 'common/common.dart';
import 'page/cn/constant.dart';
import 'page/cn/native/custom_splash_page.dart';

/// 使用本插件需要知道的几个类，基本覆盖了开始使用时需要用到的入口类
///
/// [pangle] 加载广告的核心工具类
/// [PangleHelper] 辅助加载广告使用的帮助类
/// [PangleExpressSize] 模板类广告请求宽高设置
///
/// [PangleResult] 普通加载广告返回的结果
///
/// [SplashView] 开屏广告Widget
///
/// [PangleAd] 信息流加载获得的数据源
/// [FeedView] 信息流广告Widget
///
/// [NativeBannerView] 横幅广告Widget
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initPangle();
  runApp(PangleApp());
}

/// 范例入口
class PangleApp extends StatelessWidget {
  const PangleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      ///
      home: CustomSplashPage(isRoot: true),
      theme: kThemeData,
    );
  }
}

/// 初始化广告sdk
///
/// 工具类根据平台不同会有不同的配置
/// [iOS] iOS平台配置参数
/// [android] android平台配置参数
Future<Null> initPangle() async {
  await pangle.init(
    iOS: IOSConfig(
      appId: kAppId,
      logLevel: PangleLogLevel.error,
    ),
    android: AndroidConfig(
        appId: kAppId,
        debug: false,
        allowShowNotify: true,
        allowShowPageWhenScreenLock: false,
        directDownloadNetworkType: [
          AndroidDirectDownloadNetworkType.k2G,
        ]),
  );
}
