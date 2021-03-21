//
//  BannerViewFactory.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/19.
//

import Flutter

public class BannerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: NSObjectProtocol & FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        FLTBannerView(frame, id: viewId, params: (args as? [String: Any?]) ?? [:], messenger: messenger)
    }
}
