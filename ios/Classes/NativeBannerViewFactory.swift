//
//  NativeBannerViewFactory.swift
//  pangle_flutter
//

import Flutter

public class NativeBannerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: NSObjectProtocol & FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        FLTNativeBannerView(frame, id: viewId, params: (args as? [String: Any?]) ?? [:], messenger: messenger)
    }
}
