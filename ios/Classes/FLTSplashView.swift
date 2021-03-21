//
//  FLTSplashView.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/11/5.
//

import BUAdSDK
import Flutter
import WebKit

public class FLTSplashView: NSObject, FlutterPlatformView {
    private let methodChannel: FlutterMethodChannel
    private let container: SplashView
    private weak var bannerView: BUNativeExpressSplashView?

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_splashview_%lld", id)
        methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        container = SplashView(frame: frame, params: params, methodChannel: methodChannel)
        super.init()
        container.autoresizesSubviews = true

//        let gesture = UITapGestureRecognizer()
//        gesture.delegate = self.uiGesture
//        container.addGestureRecognizer(gesture)


    }

    public func view() -> UIView {
        container
    }

    deinit {
        container.removeFromSuperview()
    }
}


extension SplashView: BUSplashAdDelegate {
    public func splashAdCountdown(toZero splashAd: BUSplashAdView) {
        postMessage("onTimeOver")
    }

    public func splashAdDidClick(_ splashAd: BUSplashAdView) {
        postMessage("onClick")
    }

    public func splashAdDidClose(_ splashAd: BUSplashAdView) {
    }

    public func splashAdDidClickSkip(_ splashAd: BUSplashAdView) {
        postMessage("onSkip")
    }

    public func splashAdWillVisible(_ splashAd: BUSplashAdView) {
        postMessage("onShow")
    }

    public func splashAdDidLoad(_ splashAd: BUSplashAdView) {
    }

    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
        let e = error as NSError?
        postMessage("onError", arguments: ["code": e?.code ?? -1, "message": e?.localizedDescription])
    }

    private func postMessage(_ method: String, arguments: [String: Any?] = [:]) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }
}

class SplashView: UIView {

    private var mounted: Bool = false
    private var params: [String: Any?] = [:]
    private var methodChannel: FlutterMethodChannel? = nil

    init(frame: CGRect, params: [String: Any?], methodChannel: FlutterMethodChannel) {
        self.params = params
        self.methodChannel = methodChannel
        super.init(frame: frame)

        methodChannel.setMethodCallHandler(self.handle(_:result:))
    }

    deinit {
        methodChannel?.setMethodCallHandler(nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
        switch call.method {
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    override func layoutSubviews() {

        if !mounted {
            mounted = true
            loadSplash()
        }
        super.layoutSubviews()
    }

    private func loadSplash() {
        let slotId: String = params["slotId"] as! String
        let tolerateTimeout: Double? = params["tolerateTimeout"] as? Double
        let hideSkipButton: Bool? = params["hideSkipButton"] as? Bool

        let splashAdView = BUSplashAdView(slotID: slotId, frame: frame)
        splashAdView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        let vc = AppUtil.getVC()
        splashAdView.rootViewController = vc
        if tolerateTimeout != nil {
            splashAdView.tolerateTimeout = tolerateTimeout!
        }
        if hideSkipButton != nil {
            splashAdView.hideSkipButton = hideSkipButton!
        }
        splashAdView.delegate = self

        addSubview(splashAdView)
        splashAdView.loadAdData()
    }
}
