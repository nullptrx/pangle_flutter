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

class BannerView extends StatefulWidget {
  final IOSBannerAdConfig iOS;
  final AndroidBannerAdConfig android;

  const BannerView({
    Key key,
    this.iOS,
    this.android,
    this.onBannerViewCreated,
  }) : super(key: key);

  final BannerViewCreatedCallback onBannerViewCreated;

  @override
  State<StatefulWidget> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> with AutomaticKeepAliveClientMixin {
  BannerViewController _controller;
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
          viewType: kBannerViewType,
          onPlatformViewCreated: (index) => _onPlatformViewCreated(context, index),
          creationParams: _createParams(),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.rtl,
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platformView = UiKitView(
          viewType: kBannerViewType,
          onPlatformViewCreated: (index) => _onPlatformViewCreated(context, index),
          creationParams: _createParams(),
          creationParamsCodec: const StandardMessageCodec(),
          // BannerView content is not affected by the Android view's layout direction,
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

  @override
  void didUpdateWidget(BannerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != this) {
      _controller?._update(_createParams());
    }
  }

  void _onPlatformViewCreated(BuildContext context, int id) {
    var controller = BannerViewController._(id, context, this);
    _controller = controller;
    _controller.methodHandler.listen((event) {
      if (event == BannerMethod.remove) {
        setState(() {
          this.offstage = true;
          this.adWidth = kPangleSize;
          this.adHeight = kPangleSize;
        });
      }
    });
    _loadAd(controller);
    if (widget.onBannerViewCreated == null) {
      return;
    }
    widget.onBannerViewCreated(controller);
  }

  void _loadAd(BannerViewController controller) async {
    if (controller == null) {
      return;
    }
    final data = await controller?.loadAd(
      iOS: widget.iOS,
      android: widget.android,
    );
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

  void updateWidget(BuildContext context, bool success) {
    if (mounted) {
      setState(() {
        offstage = !success;
      });
    }
  }

  @override
  void dispose() {
    _controller.destroy();
    super.dispose();
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
  _BannerViewState _state;
  BuildContext _context;
  final _streamController = StreamController<BannerMethod>.broadcast(sync: false);

  Stream<BannerMethod> get methodHandler {
    return _streamController.stream;
  }

  void destroy() {
    _context = null;
    _state = null;
    _streamController.close();
  }

  BannerViewController._(int id, BuildContext context, _BannerViewState state) {
    _context = context;
    _state = state;
    _methodChannel = new MethodChannel('${kBannerViewType}_$id');
    _methodChannel.setMethodCallHandler((call) {
      switch (call.method) {
        case 'reload':
          _streamController.add(BannerMethod.reload);
          break;
        case 'remove':
          _streamController.add(BannerMethod.remove);
          break;
      }
    });
  }

  /// Request banner ad data.
  ///
  /// [iOS] config for iOS
  /// [android] config for Android
  Future<Map<String, dynamic>> loadAd({
    IOSBannerAdConfig iOS,
    AndroidBannerAdConfig android,
  }) async {
    if (Platform.isIOS && iOS != null) {
      return await _methodChannel.invokeMapMethod('load', iOS.toJSON());
    } else if (Platform.isAndroid && android != null) {
      return await _methodChannel.invokeMapMethod('load', android.toJSON());
    }
    return {};
  }

  Future<Null> _update(Map<String, dynamic> params) async {
    await _methodChannel?.invokeMethod('update', params);
  }
}
