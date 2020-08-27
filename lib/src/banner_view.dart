import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config_android.dart';
import 'config_ios.dart';
import 'size.dart';

final kBannerViewType = 'nullptrx.github.io/pangle_bannerview';

typedef void BannerViewCreatedCallback(BannerViewController controller);

/// Display banner AD
/// PlatformView does not support Android API level 19 or below.
class BannerView extends StatefulWidget {
  final IOSBannerConfig iOS;
  final AndroidBannerConfig android;
  final VoidCallback onRemove;
  final BannerViewCreatedCallback onBannerViewCreated;

  BannerView({
    Key key,
    this.iOS,
    this.android,
    this.onBannerViewCreated,
    this.onRemove,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BannerViewState();
}

class BannerViewKey extends GlobalObjectKey {
  const BannerViewKey(Object value) : super(value);
}

class _BannerViewState extends State<BannerView>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  BannerViewController _controller;
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    clear();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    var size = WidgetsBinding.instance.window.physicalSize;
    if (_lastSize == null) {
      _lastSize = size;
      _controller?._update(_createParams());
    } else if (_lastSize.width != size.width ||
        _lastSize.height != size.height) {
      _controller?._update(_createParams());
    }
  }

  void clear() {
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
          viewType: kBannerViewType,
          onPlatformViewCreated: (index) =>
              _onPlatformViewCreated(context, index),
          creationParams: _createParams(),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.ltr,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView = UiKitView(
          viewType: kBannerViewType,
          onPlatformViewCreated: (index) =>
              _onPlatformViewCreated(context, index),
          creationParams: _createParams(),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
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

    var controller =
        BannerViewController._(id, onRemove: removed, onUpdate: updated);
    _controller = controller;
    if (widget.onBannerViewCreated == null) {
      return;
    }
    widget.onBannerViewCreated(controller);
  }

  void updateWidget(BuildContext context, bool success) {
    if (mounted) {
      setState(() {
        offstage = !success;
      });
    }
  }

  Map<String, dynamic> _createParams() {
    if (Platform.isIOS && widget.iOS != null) {
      return widget.iOS.toJSON();
    } else if (Platform.isAndroid && widget.android != null) {
      return widget.android.toJSON();
    }
    return {};
  }
}

enum BannerMethod {
  remove,
  reload,
}

class BannerViewController {
  MethodChannel _methodChannel;
  final VoidCallback onRemove;
  final SizeCallback onUpdate;

  BannerViewController._(
    int id, {
    this.onRemove,
    this.onUpdate,
  }) {
    _methodChannel = new MethodChannel('${kBannerViewType}_$id');
    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  void clear() {
    this._methodChannel = null;
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
    await _methodChannel?.invokeMethod('update', params);
  }
}
