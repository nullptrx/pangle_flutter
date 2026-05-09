//
//  FLTFeedView.swift
//  ttad
//
//  Created by Jerry on 2020/7/19.
//

import BUAdSDK
import Flutter
import WebKit

public class FLTFeedView: NSObject, FlutterPlatformView {
    private let container: FeedView
    private var id: String?

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_feedview_%ld", id)
        let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        container = FeedView(frame: frame, params: params, methodChannel: methodChannel)
        super.init()
    }
    
    public func view() -> UIView {
        container
    }
    
    deinit {
        UIUtil.removeAllView(container)
        // Remove the cached ad entry so the backing BUNativeExpressAdView can be released.
        // If the ad was already consumed (rendered), removeExpressAd returns false — that's fine.
        PangleAdManager.shared.removeExpressAd(container.id)
    }
}


class FeedView: FLTView {

    private var methodChannel: FlutterMethodChannel? = nil
    private var params: [String: Any?] = [:]
   

    var id: String = ""

    init(frame: CGRect, params: [String: Any?], methodChannel: FlutterMethodChannel) {
        self.params = params
        self.methodChannel = methodChannel
        super.init(frame: frame)
        methodChannel.setMethodCallHandler(handle(_:result:))
        loadExpressAd()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        methodChannel?.setMethodCallHandler(nil)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "addTouchableBounds":
            let args: [[String: Double?]] = call.arguments as? [[String: Double?]] ?? [[:]]
            addTouchableBounds(bounds: args)
        case "clearTouchableBounds":
            clearTouchableBounds()
        default:
            result(FlutterMethodNotImplemented)
        }

    }
  
    private func loadExpressAd() {
        guard let id = params["id"] as? String else {
            return
        }
        self.id = id
        guard let expressAd = PangleAdManager.shared.getExpressAd(id) else {
            // Ad was not found in the cache — notify Dart so it can show a placeholder or retry.
            methodChannel?.invokeMethod("onRenderFail", arguments: ["code": -1, "message": "Ad not ready (id=\(id))"])
            return
        }
        expressAd.rootViewController = AppUtil.getVC()
        expressAd.extraChannel = methodChannel

        addSubview(expressAd)

        expressAd.render()
    }
}
