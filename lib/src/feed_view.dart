import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  /// [isUserInteractionEnabled] 广告位是否可点击，true可以，false不可以
  ///   only works for iOS
  FeedView({
    Key key,
    this.id,
    this.isExpress = true,
    this.onRemove,
    this.isUserInteractionEnabled,
  })  : assert(id.isNotBlank),
        super(key: key ?? FeedViewKey(id));

  @override
  State<StatefulWidget> createState() => FeedViewState();
}

class FeedViewKey extends GlobalObjectKey {
  const FeedViewKey(Object value) : super(value);
}

class FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final platformViewKey = GlobalKey();

  FeedViewController _controller;
  bool _offstage = true;
  bool _removed = false;
  double _itemWidth = kPangleSize;
  double _itemHeight = kPangleSize;

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
    _remove();
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_removed) {
      return SizedBox.shrink();
    }
    Widget body;
    Widget platformView;
    try {
      final Map<String, dynamic> creationParams = _createParams();
      if (defaultTargetPlatform == TargetPlatform.android) {
        platformView = PlatformViewLink(
            key: platformViewKey,
            surfaceFactory:
                (BuildContext context, PlatformViewController controller) {
              return AndroidViewSurface(
                controller: controller,
                gestureRecognizers: const <
                    Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            viewType: kFeedViewType,
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: kFeedViewType,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams,
                creationParamsCodec: StandardMessageCodec(),
              )
                ..addOnPlatformViewCreatedListener((id) async {
                  params.onPlatformViewCreated(id);
                  _onPlatformViewCreated(context, id);
                })
                ..create();
            });
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView = UiKitView(
          viewType: kFeedViewType,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (id) => _onPlatformViewCreated(context, id),
          // FeedView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.ltr,
        );
      } else {
        platformView = Container(
          alignment: Alignment.center,
          child: Text('Not supported platform!'),
        );
      }
    } on PlatformException {}
    if (platformView != null) {
      body = Offstage(
        offstage: _offstage,
        child: SizedBox(
          width: _itemWidth,
          height: _itemHeight,
          child: platformView,
        ),
      );
    }

    if (body == null) {
      body = SizedBox.shrink();
    }
    return body;
  }

  /// 设置广告位是否可以点击，默认true
  /// [enable]
  void setUserInteractionEnabled(bool enable) {
    _controller?.setUserInteractionEnabled(enable);
  }

  void _remove() {
    _controller?.remove();
    _controller = null;
  }

  void _onPlatformViewCreated(BuildContext context, int id) {
    final removed = () {
      if (widget.onRemove != null) {
        widget.onRemove();
      } else {
        if (mounted) {
          setState(() {
            this._removed = true;
          });
        }
      }
    };
    final updated = (args) {
      double width = args['width'];
      double height = args['height'];
      if (mounted) {
        setState(() {
          this._offstage = false;
          this._itemWidth = width;
          this._itemHeight = height;
        });
      }
    };
    final controller = FeedViewController._(
      id,
      onRemove: removed,
      onUpdate: updated,
    );
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

  void remove() {
    _methodChannel.invokeMethod('remove');
  }

  void setUserInteractionEnabled(bool enable) {
    if (Platform.isIOS) {
      _methodChannel.invokeMethod("setUserInteractionEnabled", enable ?? false);
    }
  }
}
