//
//  FLTBannerView.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/19.
//

import BUAdSDK
import Flutter

public class FLTBannerView: NSObject, FlutterPlatformView {
    private let methodChannel: FlutterMethodChannel
    private let container: UIView
    private var contentView: UIView?
    private var methodResult: FlutterResult?

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        self.container = UIView(frame: frame)
        let channelName = String(format: "nullptrx.github.io/pangle_bannerview_%lld", id)
        self.methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        super.init()
        self.methodChannel.setMethodCallHandler(self.handle(_:result:))
    }

    public func view() -> UIView {
        return self.container
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.methodResult = result
        let args: [String: Any?] = call.arguments as? [String: Any?] ?? Dictionary()
        switch call.method {
        case "load", "reload":
            guard let vc = AppUtil.getCurrentVC() else {
                result(FlutterError(code: "-1", message: "No vc", details: nil))
                return
            }

            let slotId = args["slotId"] as! String
            let imgSizeIndex = args["imgSize"] as! Int
            let imgSize = BUSize(by: BUProposalSize(rawValue: imgSizeIndex)!)!
            let screenWidth = Double(UIScreen.main.bounds.width)
            let bannerHeight = screenWidth * Double(imgSize.height) / Double(imgSize.width)

            let bannerAdView = BUBannerAdView(slotID: slotId, size: imgSize, rootViewController: vc)
            bannerAdView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
            bannerAdView.delegate = self
            bannerAdView.loadAdData()
            bannerAdView.updateConstraints()
            self.contentView = bannerAdView
            self.container.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
            self.container.addSubview(bannerAdView)
            self.container.updateConstraints()
        case "update":
            if self.contentView != nil {
                let imgSizeIndex = args["imgSize"] as! Int
                let imgSize = BUSize(by: BUProposalSize(rawValue: imgSizeIndex)!)!
                let screenWidth = Double(UIScreen.main.bounds.width)
                let bannerHeight = screenWidth * Double(imgSize.height) / Double(imgSize.width)
                self.contentView!.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
                self.container.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
                self.container.updateConstraints()
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension FLTBannerView: BUBannerAdViewDelegate {
    public func bannerAdView(_ bannerAdView: BUBannerAdView, didLoadFailWithError error: Error?) {
        self.invoke(message: error?.localizedDescription)
    }

    public func bannerAdViewDidLoad(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {
        let frame = bannerAdView.frame
        self.invoke(width: frame.width, height: frame.height)
    }

    public func bannerAdViewDidClick(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {}

    public func bannerAdView(_ bannerAdView: BUBannerAdView, dislikeWithReason filterwords: [BUDislikeWords]?) {
        bannerAdView.removeFromSuperview()
        self.contentView = nil
        self.methodChannel.invokeMethod("remove", arguments: nil)
    }

    func invoke(message: String? = "") {
        guard let result = self.methodResult else {
            return
        }

        let params = NSMutableDictionary()
        params["success"] = false
        params["message"] = message
        result(params)
        self.methodResult = nil
    }

    private func invoke(width: CGFloat, height: CGFloat) {
        guard let result: FlutterResult = self.methodResult else {
            return
        }
        var params = [String: Any?]()
        params["success"] = true
        params["width"] = width
        params["height"] = height
        result(params)
        self.methodResult = nil
    }
}
