//
//  SplashViewFactory.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/11/5.
//

import Flutter

public class SplashViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: NSObjectProtocol & FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return FLTSplashView(frame, id: viewId, params: (args as? [String: Any?]) ?? [:], messenger: messenger)
    }
}
