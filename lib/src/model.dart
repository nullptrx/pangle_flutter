class PangleFeedAd {
  final int code;
  final String message;
  final int count;
  final List<String> data;

  PangleFeedAd.empty()
      : code = -1,
        message = "",
        count = 0,
        data = [];

  PangleFeedAd.fromJsonMap(Map<dynamic, dynamic> map)
      : code = map["code"],
        message = map["message"],
        count = map["count"],
        data = List<String>.from(map["data"]);
}
