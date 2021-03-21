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
    private let widget: FeedView
    private var id: String?

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_feedview_%ld", id)
        let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        widget = FeedView(frame: frame, params: params, methodChannel: methodChannel)
        super.init()
    }

    deinit {
        removeAllView()
    }

    public func view() -> UIView {
        widget
    }

    private func removeAllView() {
        widget.subviews.forEach {
            if $0 is BUNativeExpressAdView {
                let v = $0 as! BUNativeExpressAdView
                v.extraDelegate = nil
                v.extraManager = nil
                v.extraChannel = nil
                v.subviews.forEach {
                    if String(describing: $0.classForCoder) == "BUWKWebViewClient" {
                        let webview = $0 as! WKWebView
                        webview.navigationDelegate = nil
                        if #available(iOS 14.0, *) {
                            webview.configuration.userContentController.removeAllScriptMessageHandlers()
                        } else {
                            webview.configuration.userContentController.removeScriptMessageHandler(forName: "callMethodParams")
                        }
                    }
                }
            }
            $0.subviews.forEach {
                $0.removeFromSuperview()
            }
            $0.removeFromSuperview()
        }
        widget.removeFromSuperview()
    }


}


class FeedView: UIView {

    private var methodChannel: FlutterMethodChannel? = nil
    private var params: [String: Any?] = [:]
    private var touchableBounds: [CGRect] = []
    private var restrictedBounds: [CGRect] = []

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

//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let windowPoint = self.convert(point, to: UIApplication.shared.delegate?.window!!)
//        if windowPoint.y < UIScreen.main.bounds.size.height - 49 {
//            return super.hitTest(point, with: event)
//        }
//       return super.hitTest(point, with: event)
//    }
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let windowPoint = self.convert(point, to: UIApplication.shared.delegate?.window!!)
        var touchable = false
        var restricted = false

        if touchableBounds.isEmpty {
            touchable = true
        }
        for bound in touchableBounds {
            if bound.contains(windowPoint) {
                touchable = true
                break
            }
        }
        for bound in restrictedBounds {
            if bound.contains(windowPoint) {
                restricted = true
                break
            }
        }

        if touchable && !restricted {
            return super.hitTest(_: point, with: event)
        }

        return self
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateTouchableBounds":
            let args: [[String: Double?]] = call.arguments as? [[String: Double?]] ?? [[:]]
            updateTouchableBounds(bounds: args)
        case "updateRestrictedBounds":
            let args: [[String: Double?]] = call.arguments as? [[String: Double?]] ?? [[:]]
            updateRestrictedBounds(bounds: args)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func updateTouchableBounds(bounds: [[String: Double?]]) {
        touchableBounds.removeAll()
        for bound in bounds {
            let w = bound["w"] ?? 0
            let h = bound["h"] ?? 0
            if w == nil || h == nil {
                continue
            }
            let x = bound["x"] ?? 0
            let y = bound["y"] ?? 0
            touchableBounds.append(CGRect(x: x!, y: y!, width: w!, height: h!))
        }
    }

    private func updateRestrictedBounds(bounds: [[String: Double?]]) {
        restrictedBounds.removeAll()
        for bound in bounds {
            let w = bound["w"] ?? 0
            let h = bound["h"] ?? 0
            if w == nil || h == nil {
                continue
            }
            let x = bound["x"] ?? 0
            let y = bound["y"] ?? 0
            restrictedBounds.append(CGRect(x: x!, y: y!, width: w!, height: h!))
        }
    }

    private func loadExpressAd() {
        guard let id = params["id"] as? String else {
            return
        }
        self.id = id
        let ad = PangleAdManager.shared.getExpressAd(id)
        guard let expressAd: BUNativeExpressAdView = ad else {
            return
        }
        expressAd.rootViewController = AppUtil.getVC()
        expressAd.extraChannel = methodChannel

        addSubview(expressAd)

        expressAd.render()
    }
}
