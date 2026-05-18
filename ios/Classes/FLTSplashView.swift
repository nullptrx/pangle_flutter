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

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_splashview_%lld", id)
        methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    
        container = SplashView(frame: frame, params: params, methodChannel: methodChannel)
        super.init()
        container.autoresizesSubviews = true

//        let gesture = UITapGestureRecognizer()
//        gesture.delegate = self.uiGesture
//        container.addGestureRecognizer(gesture)

        container.loadSplash()
    }

    public func view() -> UIView {
        container
    }

    deinit {
        UIUtil.removeAllView(container)
    }
}

extension SplashView: BUSplashAdDelegate {
    func splashAdRenderSuccess(_ splashAd: BUSplashAd) {
        if let splashView = splashAd.splashView {
            for sub in self.subviews {
                sub.removeFromSuperview()
            }
            splashView.frame = self.bounds
            self.addSubview(splashView)
        }
    }

    func splashAdRenderFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        postMessage("onRenderFail", arguments: ["code": error?.errorCode ?? -1, "message": error?.localizedDescription])
    }
    
    func splashAdWillShow(_ splashAd: BUSplashAd) {
        
    }
    
    func splashAdDidClose(_ splashAd: BUSplashAd, closeType: BUSplashAdCloseType) {
        postMessage("onClose", arguments: ["type": closeType.rawValue])
    }
    
    func splashDidCloseOtherController(_ splashAd: BUSplashAd, interactionType: BUInteractionType) {
        
    }
    
    func splashVideoAdDidPlayFinish(_ splashAd: BUSplashAd, didFailWithError error: Error?) {
        
    }
    
    func splashAdDidClick(_ splashAd: BUSplashAd) {
        postMessage("onClick")
    }
    
    func splashAdLoadSuccess(_ splashAd: BUSplashAd) {
        postMessage("onLoad")
    }
    
    func splashAdLoadFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        postMessage("onError", arguments: ["code": error?.errorCode ?? -1, "message": error?.localizedDescription])
    }
    

    func splashAdDidShow(_ splashAd: BUSplashAd) {
        postMessage("onShow")
    }
    
    func splashAdViewControllerDidClose(_ splashAd: BUSplashAd) {
        
    }

    private func postMessage(_ method: String, arguments: [String: Any?] = [:]) {
        methodChannel?.invokeMethod(method, arguments: arguments)
    }
}

class SplashView: FLTView {
    private var splashAd: BUSplashAd? = nil
    private var mounted: Bool = false
    private var params: [String: Any?] = [:]
    private var methodChannel: FlutterMethodChannel?

    init(frame: CGRect, params: [String: Any?], methodChannel: FlutterMethodChannel) {
        self.params = params
        self.methodChannel = methodChannel
        let expressArgs = params["expressSize"] as? [String: Double] ?? [:]
        let uiframe = UIScreen.main.bounds
        let width: Double = expressArgs["width"] ?? Double(uiframe.width)
        let height: Double = expressArgs["height"] ?? Double(uiframe.height)
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        super.init(frame: frame)

        methodChannel.setMethodCallHandler(handle(_:result:))
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
        case "addTouchableBounds":
            let args: [[String: Double?]] = call.arguments as? [[String: Double?]] ?? [[:]]
            addTouchableBounds(bounds: args)
        case "clearTouchableBounds":
            clearTouchableBounds()
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func loadSplash() {
        let slotId: String = params["slotId"] as! String
        let tolerateTimeout: Double? = params["tolerateTimeout"] as? Double
        let hideSkipButton: Bool? = params["hideSkipButton"] as? Bool

        let splashAd = BUSplashAd(slotID: slotId, adSize: frame.size)

        if let tolerateTimeout = tolerateTimeout {
            splashAd.tolerateTimeout = tolerateTimeout
        }
        if let hideSkipButton = hideSkipButton {
            splashAd.hideSkipButton = hideSkipButton
        }
        splashAd.delegate = self

        splashAd.loadData()
        self.splashAd = splashAd
    }
    
}
