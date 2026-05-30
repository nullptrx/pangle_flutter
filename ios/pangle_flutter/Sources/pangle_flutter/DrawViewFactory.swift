//
//  DrawViewFactory.swift
//  pangle_flutter
//

import Flutter

public class DrawViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(
        withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
    ) -> FlutterPlatformView {
        FLTDrawView(
            frame, id: viewId,
            params: (args as? [String: Any?]) ?? [:] as [String: Any?],
            messenger: messenger)
    }
}
