//
//  FLTDrawView.swift
//  pangle_flutter
//

import BUAdSDK
import Flutter
import WebKit

public class FLTDrawView: NSObject, FlutterPlatformView {
    private let container: DrawView
    private var id: String?

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_drawview_%ld", id)
        let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        container = DrawView(frame: frame, params: params, methodChannel: methodChannel)
        super.init()
    }

    public func view() -> UIView {
        container
    }

    deinit {
        UIUtil.removeAllView(container)
        PangleAdManager.shared.removeExpressAd(container.id)
    }
}

class DrawView: FLTView {
    private var methodChannel: FlutterMethodChannel?
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
        guard let id = params["id"] as? String else { return }
        self.id = id
        guard let expressAd = PangleAdManager.shared.getExpressAd(id) else {
            methodChannel?.invokeMethod(
                "onRenderFail",
                arguments: ["code": -1, "message": "Ad not ready (id=\(id))"])
            return
        }
        expressAd.rootViewController = AppUtil.getVC()
        expressAd.extraChannel = methodChannel

        addSubview(expressAd)
        expressAd.render()
    }
}
