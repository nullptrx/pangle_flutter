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
