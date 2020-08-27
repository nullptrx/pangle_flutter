import 'package:pangle_flutter/pangle_flutter.dart';

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

/// expect size
class PangleExpectSize {
  final double width;
  final double height;

  /// Android的express广告如果需要自定义宽高，如果不想广告变形，只需要提供[width]或
  /// [height]其中一个即可。之后会以期望[PangleImgSize]的广告宽高进行缩放。
  ///
  /// [width] 宽度，可选
  /// [height] 高度，可选
  PangleExpectSize({this.width, this.height});

  Map<String, dynamic> toJSON() {
    return {
      'width': width,
      'height': height,
    };
  }
}
