//
//  FeedViewFactory.swift
//  ttad
//
//  Created by Jerry on 2020/7/19.
//

import Flutter

public class FeedViewFactory: NSObject, FlutterPlatformViewFactory {
    public static func initWithMessenger(with messenger: FlutterBinaryMessenger) -> BannerViewFactory {
        let instance = BannerViewFactory(messenger: messenger)
        return instance
    }

    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        FLTFeedView(frame, id: viewId, params: (args as? [String: Any?]) ?? [:] as [String: Any?], messenger: messenger)
    }
}
