import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'size.dart';

final kFeedViewType = 'nullptrx.github.io/pangle_feedview';

typedef void FeedViewCreatedCallback(FeedViewController controller);

class FeedView extends StatefulWidget {
  final String tag;
  final FeedViewCreatedCallback onCreated;

  const FeedView({
    Key key,
    this.onCreated,
    this.tag,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> with AutomaticKeepAliveClientMixin {
  FeedViewController _controller;
  bool offstage = true;
  double adWidth = kPangleSize;
  double adHeight = kPangleSize;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    Widget body;
    try {
      Widget platformView;
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformView = AndroidView(
          viewType: kFeedViewType,
          creationParams: _createParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (id) => _onPlatformViewCreated(context, id),
          // FeedView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.rtl,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView = UiKitView(
          viewType: kFeedViewType,
          creationParams: _createParams(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (id) => _onPlatformViewCreated(context, id),
          // FeedView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.rtl,
        );
      }
      if (platformView != null) {
        body = Offstage(
          offstage: offstage,
          child: Container(
            color: Colors.white,
            width: adWidth,
            height: adHeight,
            child: platformView,
          ),
        );
      }
    } on PlatformException catch (e) {}

    if (body == null) {
      body = Container();
    }
    return body;
  }

  void _onPlatformViewCreated(BuildContext context, int id) {
    final controller = FeedViewController._(
      id,
      onRemoved: () {
        setState(() {
          this.offstage = true;
          this.adWidth = kPangleSize;
          this.adHeight = kPangleSize;
        });
      },
    );
    _controller = controller;
    _loadAd(context, controller);
    if (widget.onCreated != null) {
      widget.onCreated(controller);
    }
  }

  Future<Null> _loadAd(BuildContext context, FeedViewController controller) async {
    if (controller == null) {
      return;
    }
    final data = await controller.loadAd(tag: widget.tag);
    if (data['success'] ?? false) {
      double width = data['width'];
      double height = data['height'];

      if (mounted) {
        setState(() {
          this.offstage = false;
          this.adWidth = width;
          this.adHeight = height;
        });
      }
    }
  }

  @override
  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != this) {
      _controller?._update(_createParams());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<String, dynamic> _createParams() {
    return {};
  }
}

enum FeedMethod {
  remove,
}

class FeedViewController {
  MethodChannel _methodChannel;
  final VoidCallback onRemoved;

  FeedViewController._(
    int id, {
    this.onRemoved,
  }) {
    _methodChannel = new MethodChannel('${kFeedViewType}_$id');
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    switch (call.method) {
      case 'remove':
        if (onRemoved != null) {
          onRemoved();
        }
        break;
      default:
        break;
    }
  }

  Future<Map<String, dynamic>> loadAd({String tag}) async {
    return await _methodChannel.invokeMapMethod<String, dynamic>("load", {
      'tag': tag,
    });
  }

  Future<Null> _update(Map<String, dynamic> params) async {
    await _methodChannel?.invokeMethod("update", params);
  }
}
