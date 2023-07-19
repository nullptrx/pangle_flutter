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

import 'dart:convert';
import 'dart:ui';

import 'constant.dart';

/// 信息流响应信息
///
/// [code] 响应码，0成功，-1失败
/// [message] 错误时，调试信息
/// [count] 获得信息流数量，一般同上面传入的count，最终结果以此count为主
/// [data] (string list) 用于展示信息流广告的键id
class PangleAd {
  final int code;
  final String? message;
  final int count;
  final List<String> data;

  /// 是否成功
  bool get ok => code == 0;

  /// response for loading feed ad
  PangleAd.empty()
      : code = -1,
        message = "",
        count = 0,
        data = [];

  /// response for loading feed ad
  PangleAd.fromJsonMap(Map<dynamic, dynamic> map)
      : code = map["code"],
        message = map["message"],
        count = map["count"],
        data = map["data"] == null ? [] : List<String>.from(map["data"]);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'message': message,
      'count': count,
      'data': data,
    };
  }
}

/// GPS location
class PangleLocation {
  final double latitude;
  final double longitude;

  /// [latitude] 纬度
  /// [longitude] 经度
  PangleLocation({
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  Map<String, double> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// PlatformDispatcher.instance.views.first.physicalSize
// WidgetsBinding.instance.platformDispatcher.views.first.physicalSize
final _kPhysicalSize = PlatformDispatcher.instance.views.first.physicalSize;
final _kDevicePixelRatio = _kPhysicalSize.aspectRatio;

final kPangleScreenWidth = _kPhysicalSize.width / _kDevicePixelRatio;
final kPangleScreenHeight = _kPhysicalSize.height / _kDevicePixelRatio;

/// expect size
class PangleExpressSize {
  final double width;
  final double height;

  /// 模板渲染时必填
  ///
  /// [width] 宽度，必选, 如果width超过屏幕，默认使用屏幕宽
  /// [height] 高度，必选
  PangleExpressSize({required double width, required double height})
      : assert(width > 0),
        assert(height > 0),
        width = width > kPangleScreenWidth ? kPangleScreenWidth : width,
        height = height > kPangleScreenWidth / width * height
            ? kPangleScreenWidth / width * height
            : height;

  /// 模板渲染时必填
  ///
  /// [aspectRatio] item宽高比例
  PangleExpressSize.aspectRatio(double aspectRatio)
      : assert(aspectRatio > 0),
        width = kPangleScreenWidth,
        height = kPangleScreenWidth / aspectRatio;

  PangleExpressSize.aspectRatio9_16()
      : width = kPangleScreenWidth,
        height = kPangleScreenWidth / 0.5625;

  PangleExpressSize.aspectRatio16_9()
      : width = kPangleScreenWidth,
        height = kPangleScreenWidth * 0.5625;

  PangleExpressSize.percent(double widthPercent, double heightPercent)
      : width = kPangleScreenWidth * widthPercent,
        height = kPangleScreenHeight * heightPercent;

  PangleExpressSize.widthPercent(double widthPercent,
      {required double aspectRatio})
      : width = kPangleScreenWidth * widthPercent,
        height = kPangleScreenWidth * widthPercent / aspectRatio;

  PangleExpressSize.heightPercent(double heightPercent,
      {required double aspectRatio})
      : width = kPangleScreenHeight * heightPercent * aspectRatio,
        height = kPangleScreenHeight * heightPercent;

  PangleExpressSize.wrap({required this.width}) : height = 0;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'width': width,
      'height': height,
    };
  }
}

/// image size
class PangleSize {
  final double width;
  final double height;

  /// 自渲染时必填
  ///
  /// [width] 宽度，必选, 如果width超过屏幕，默认使用屏幕宽
  /// [height] 高度，必选
  PangleSize({required double width, required double height})
      : assert(width > 0),
        assert(height > 0),
        width = width > kPangleScreenWidth ? kPangleScreenWidth : width,
        height = height > kPangleScreenWidth / width * height
            ? kPangleScreenWidth / width * height
            : height;

  /// [aspectRatio] item宽高比例
  PangleSize.aspectRatio(double aspectRatio)
      : assert(aspectRatio > 0),
        width = kPangleScreenWidth,
        height = kPangleScreenWidth / aspectRatio;

  PangleSize.aspectRatio9_16()
      : width = kPangleScreenWidth,
        height = kPangleScreenWidth / 0.5625;

  PangleSize.aspectRatio16_9()
      : width = kPangleScreenWidth,
        height = kPangleScreenWidth * 0.5625;

  PangleSize.percent(double widthPercent, double heightPercent)
      : width = kPangleScreenWidth * widthPercent,
        height = kPangleScreenHeight * heightPercent;

  PangleSize.widthPercent(double widthPercent, {required double aspectRatio})
      : width = kPangleScreenWidth * widthPercent,
        height = kPangleScreenWidth * widthPercent / aspectRatio;

  PangleSize.heightPercent(double heightPercent, {required double aspectRatio})
      : width = kPangleScreenHeight * heightPercent * aspectRatio,
        height = kPangleScreenHeight * heightPercent;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'width': width,
      'height': height,
    };
  }
}

/// 插件返回的结果
///
class PangleResult {
  /// 结果码
  final int? code;

  /// 一般是错误信息
  final String? message;

  const PangleResult({this.code, this.message});

  /// 是否成功
  bool get ok => code == 0;

  /// 解析插件返回的结果
  ///
  factory PangleResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PangleResult(code: -1, message: 'unknown');
    }
    return PangleResult(
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'code': code,
      'message': message,
    };
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class PangleVerifyResult extends PangleResult {
  /// 适用于需要验证结果的广告，目前仅激励视频有返回
  final bool? verify;

  const PangleVerifyResult({
    required int code,
    required String message,
    this.verify,
  }) : super(code: code, message: message);

  /// 是否验证成功
  bool get isVerify => verify == true;

  /// 解析插件返回的结果
  ///
  factory PangleVerifyResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PangleVerifyResult(code: -1, message: 'unknown');
    }
    return PangleVerifyResult(
      code: json['code'],
      message: json['message'],
      verify: json['verify'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (verify != null) {
      data['verify'] = verify;
    }
    return data;
  }
}

class PangleSplashResult extends PangleResult {
  /// 广告关闭类型
  final PangleSplashCloseType type;

  const PangleSplashResult({
    required int code,
    required String message,
    required this.type,
  }) : super(code: code, message: message);

  /// 解析插件返回的结果
  ///
  factory PangleSplashResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PangleSplashResult(
        code: -1,
        message: 'unknown',
        type: PangleSplashCloseType.unknown,
      );
    }
    return PangleSplashResult(
      code: json['code'],
      message: json['message'],
      type: PangleSplashCloseType.values[json['type'] ?? 0],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['type'] = type.name;
    return data;
  }
}
