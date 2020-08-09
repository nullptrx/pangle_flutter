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

        self.loadAd(params)
    }

    public func view() -> UIView {
        return self.container
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
        switch call.method {
        case "update":
//            if self.contentView != nil {
//                let imgSizeIndex = args["imgSize"] as! Int
//                let imgSize = BUSize(by: BUProposalSize(rawValue: imgSizeIndex)!)!
//                let screenWidth = Double(UIScreen.main.bounds.width)
//                let bannerHeight = screenWidth * Double(imgSize.height) / Double(imgSize.width)
//                self.contentView!.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
//                self.container.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
//                self.container.updateConstraints()
//                self.invoke(width: CGFloat(screenWidth), height: CGFloat(bannerHeight))
//            }
            self.loadAd(args)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func loadAd(_ params: [String: Any?]) {
        guard let vc = AppUtil.getCurrentVC() else {
            return
        }
        let slotId = params["slotId"] as! String
        let imgSizeIndex = params["imgSize"] as! Int
        let imgSize = BUSize(by: BUProposalSize(rawValue: imgSizeIndex)!)!
        let screenWidth = Double(UIScreen.main.bounds.width)
        let bannerHeight = screenWidth * Double(imgSize.height) / Double(imgSize.width)

        self.container.subviews.forEach { $0.removeFromSuperview() }
        let bannerAdView = BUBannerAdView(slotID: slotId, size: imgSize, rootViewController: vc)
        bannerAdView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
        bannerAdView.delegate = self
        bannerAdView.loadAdData()
        bannerAdView.updateConstraints()
        self.contentView = bannerAdView
        self.container.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
        self.container.addSubview(bannerAdView)
        self.container.updateConstraints()
    }
}

extension FLTBannerView: BUBannerAdViewDelegate {
    public func bannerAdView(_ bannerAdView: BUBannerAdView, didLoadFailWithError error: Error?) {
//        self.invoke(message: error?.localizedDescription)
    }

    public func bannerAdViewDidLoad(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {
        let frame = bannerAdView.frame
        self.invoke(width: frame.width, height: frame.height)
    }

    public func bannerAdViewDidClick(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {}

    public func bannerAdView(_ bannerAdView: BUBannerAdView, dislikeWithReason filterwords: [BUDislikeWords]?) {
        bannerAdView.removeFromSuperview()
//        self.contentView = nil
        self.methodChannel.invokeMethod("remove", arguments: nil)
    }

//    func invoke(message: String? = "") {
//        guard let result = self.methodResult else {
//            return
//        }
//
//        let params = NSMutableDictionary()
//        params["success"] = false
//        params["message"] = message
//        result(params)
//        self.methodResult = nil
//    }

    private func invoke(width: CGFloat, height: CGFloat) {
        var params = [String: Any?]()
        params["width"] = width
        params["height"] = height
        self.methodChannel.invokeMethod("update", arguments: params)
    }
}
