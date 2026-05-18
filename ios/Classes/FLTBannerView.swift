//
//  FLTBannerView.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/19.
//

import BUAdSDK
import Flutter
import WebKit

public class FLTBannerView: NSObject, FlutterPlatformView {
    private let methodChannel: FlutterMethodChannel
    private let container: UIView
    private weak var bannerView: BUNativeExpressBannerView?

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_bannerview_%lld", id)
        methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        container = BannerView(frame: frame, params: params, methodChannel: methodChannel)
        super.init()
    }

    public func view() -> UIView {
        container
    }

    deinit {
        UIUtil.removeAllView(container)
    }
}

extension BannerView: BUNativeExpressBannerViewDelegate {
    public func nativeExpressBannerAdViewDidLoad(_ bannerAdView: BUNativeExpressBannerView) {
    }

    public func nativeExpressBannerAdView(_ bannerAdView: BUNativeExpressBannerView, didLoadFailWithError error: Error?) {
        let e = error as NSError?
        postMessage("onError", arguments: ["code": e?.code ?? -1, "message": e?.localizedDescription])
    }

    public func nativeExpressBannerAdViewRenderFail(_ bannerAdView: BUNativeExpressBannerView, error: Error?) {
        let e = error as NSError?
        postMessage("onRenderFail", arguments: ["code": e?.code ?? -1, "message": e?.localizedDescription])
    }
    
    public func nativeExpressBannerAdView(_ bannerAdView: BUNativeExpressBannerView, dislikeWithReason filterWords: [BUDislikeWords]?) {
        postMessage("onDislike", arguments: ["option": filterWords?.first?.name ?? "", "enforce": false])
    }

    public func nativeExpressBannerAdViewRenderSuccess(_ bannerAdView: BUNativeExpressBannerView) {
        postMessage("onRenderSuccess")
    }

    public func nativeExpressBannerAdViewDidClick(_ bannerAdView: BUNativeExpressBannerView) {
        postMessage("onClick")
    }

    public func nativeExpressBannerAdViewWillBecomVisible(_ bannerAdView: BUNativeExpressBannerView) {
        postMessage("onShow")
    }

    private func postMessage(_ method: String, arguments: [String: Any?] = [:]) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }
}

class BannerView: FLTView {

    private var methodChannel: FlutterMethodChannel? = nil
    private var params: [String: Any?] = [:]

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
        guard let slotId = params["slotId"] as? String,
              let expressArgs = params["expressSize"] as? [String: Double],
              let width = expressArgs["width"],
              let height = expressArgs["height"] else {
            return
        }
        let interval: Int? = params["interval"] as? Int
        let isUserInteractionEnabled = params["isUserInteractionEnabled"] as? Bool ?? true
        self.isUserInteractionEnabled = isUserInteractionEnabled

        let vc = AppUtil.getVC()
        let adSize = CGSize(width: width, height: height)
        let bannerAdView: BUNativeExpressBannerView
        if let interval = interval {
            bannerAdView = BUNativeExpressBannerView(slotID: slotId, rootViewController: vc, adSize: adSize, interval: interval)
        } else {
            bannerAdView = BUNativeExpressBannerView(slotID: slotId, rootViewController: vc, adSize: adSize)
        }
        bannerAdView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        addSubview(bannerAdView)
        bannerAdView.delegate = self
        bannerAdView.loadAdData()
    }

  
}
