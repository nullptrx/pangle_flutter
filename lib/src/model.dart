import 'package:flutter/cupertino.dart';

/// 信息流响应信息
///
/// [code] 响应码，0成功，-1失败
/// [message] 错误时，调试信息
/// [count] 获得信息流数量，一般同上面传入的count，最终结果以此count为主
/// [data] (string list) 用于展示信息流广告的键id
class PangleFeedAd {
  final int code;
  final String message;
  final int count;
  final List<String> data;

  /// response for loading feed ad
  PangleFeedAd.empty()
      : code = -1,
        message = "",
        count = 0,
        data = [];

  /// response for loading feed ad
  PangleFeedAd.fromJsonMap(Map<dynamic, dynamic> map)
      : code = map["code"],
        message = map["message"],
        count = map["count"],
        data = map["data"] == null ? [] : List<String>.from(map["data"]);
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

  Map<String, double> toJSON() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// express size
class PangleExpressSize {
  final double width;
  final double height;
  final double aspectRatio;

  /// 以下参数三选二，或者只选[aspectRatio]
  ///
  /// [width] 宽度，可选，[aspectRatio]为空时，不可空
  /// [height] 高度，可选，[aspectRatio]为空时，不可空
  /// [aspectRatio] 比例，[width]和[height]都为空时，将默认使用屏幕宽
  PangleExpressSize({this.width, this.height, this.aspectRatio});

  Map<String, dynamic> toJSON() {
    double w, h;
    if (width == null && height == null) {
      assert(aspectRatio != null);
      var size = WidgetsBinding.instance.window.physicalSize;
      w = size.width;
      h = size.width / aspectRatio;
    } else if (width == null) {
      assert(height != null && aspectRatio != null);
      w = height * aspectRatio;
      h = height;
    } else if (height == null) {
      assert(width != null && aspectRatio != null);
      w = width;
      h = width / aspectRatio;
    } else {
      w = width;
      h = height;
    }

    return {
      'width': w,
      'height': h,
    };
  }
}
