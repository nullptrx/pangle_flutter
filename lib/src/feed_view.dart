import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'extension.dart';
import 'size.dart';

final kFeedViewType = 'nullptrx.github.io/pangle_feedview';

/// Display feed AD
/// PlatformView does not support Android API level 19 or below.
class FeedView extends StatefulWidget {
  final String id;
  final bool isExpress;

  /// Execute default implementation, if null.
  final VoidCallback onRemove;

  final bool isUserInteractionEnabled;

  /// constructor a feed view
  ///
  /// [key] 使用GlobalObjectKey，防止Widget被多次build，导致PlatformView频繁重建
  /// [id] feedId
  /// [isExpress] optional. 个性化模板广告
  /// [onRemove] when click dislike button
  FeedView({
    Key key,
    this.id,
    this.isExpress = true,
    this.onRemove,
    this.isUserInteractionEnabled,
  })  : assert(id.isNotBlank),
        super(key: key ?? FeedViewKey(id));

  @override
  State<StatefulWidget> createState() => _FeedViewState();
}

class FeedViewKey extends GlobalObjectKey {
  const FeedViewKey(Object value) : super(value);
}

class _FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  FeedViewController _controller;
  bool offstage = true;
  bool removed = false;
  double adWidth = kPangleSize;
  double adHeight = kPangleSize;

  Size _lastSize;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    var size = WidgetsBinding.instance.window.physicalSize;
    _lastSize = size;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    remove();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    var size = WidgetsBinding.instance.window.physicalSize;
    if (_lastSize?.width != size.width || _lastSize?.height != size.height) {
      _lastSize = size;
      _controller?._update(_createParams());
    }
  }

  void remove() {
    _controller?.remove();
    _controller = null;
  }

  void clear() {
    // 从缓存里清空该键对应的广告数据
    _controller?.clear();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (removed) {
      return SizedBox.shrink();
    }
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
          child: SizedBox(
            width: adWidth,
            height: adHeight,
            child: platformView,
          ),
        );
      }
    } on PlatformException {}

    if (body == null) {
      body = SizedBox.shrink();
    }
    return body;
  }

  void _onPlatformViewCreated(BuildContext context, int id) {
    final removed = () {
      if (widget.onRemove != null) {
        widget.onRemove();
      } else {
        setState(() {
          this.removed = true;
        });
        clear();
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
      'isExpress': widget.isExpress,
      'isUserInteractionEnabled': widget.isUserInteractionEnabled,
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

  void clear() {
    _methodChannel = null;
  }

  void remove() {
    _methodChannel.invokeMethod('remove');
    clear();
  }
}
