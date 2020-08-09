import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'size.dart';

final kFeedViewType = 'nullptrx.github.io/pangle_feedview';

/// display feed AD
class FeedView extends StatefulWidget {
  final String id;

  final VoidCallback onRemove;

  /// constructor a feed view
  /// [id] feedId
  /// [onRemove] when click dislike button
  FeedView({Key key, this.id, this.onRemove}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  FeedViewController _controller;
  bool offstage = true;
  double adWidth = kPangleSize;
  double adHeight = kPangleSize;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller = null;
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _controller?._update(_createParams());
  }

  @override
  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller?._update(_createParams());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          layoutDirection: TextDirection.ltr,
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
          layoutDirection: TextDirection.ltr,
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
    } on PlatformException {}

    if (body == null) {
      body = Container();
    }
    return body;
  }

  void _onPlatformViewCreated(BuildContext context, int id) {
    final removed = () {
      if (widget.onRemove != null) {
        widget.onRemove();
      } else {
        setState(() {
          this.offstage = true;
          this.adWidth = kPangleSize;
          this.adHeight = kPangleSize;
        });
      }
    };
    final updated = (args) {
      double width = args['width'];
      double height = args['height'];
      setState(() {
        this.offstage = false;
        this.adWidth = width;
        this.adHeight = height;
      });
    };
    final controller =
        FeedViewController._(id, onRemove: removed, onUpdate: updated);
    _controller = controller;
  }

  Map<String, dynamic> _createParams() {
    return {
      'feedId': widget.id,
    };
  }
}

class FeedViewController {
  MethodChannel _methodChannel;
  final VoidCallback onRemove;
  final SizeCallback onUpdate;

  FeedViewController._(
    int id, {
    this.onRemove,
    this.onUpdate,
  }) {
    _methodChannel = new MethodChannel('${kFeedViewType}_$id');
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    switch (call.method) {
      case 'remove':
        if (onRemove != null) {
          onRemove();
        }
        break;
      case 'update':
        final params = call.arguments as Map<dynamic, dynamic>;
        if (onUpdate != null) {
          onUpdate(params);
        }
        break;
      default:
        break;
    }
    return null;
  }

  Future<Null> _update(Map<String, dynamic> params) async {
    await _methodChannel?.invokeMethod("update", params);
  }
}
