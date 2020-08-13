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
        let vc = AppUtil.getVC()
        let slotId = params["slotId"] as! String
        let imgSizeIndex = params["imgSize"] as! Int
        let imgSize = BUSize(by: BUProposalSize(rawValue: imgSizeIndex)!)!

        let isExpress = params["isExpress"] as? Bool ?? false
        let isSupportDeepLink = params["isSupportDeepLink"] as? Bool ?? true

        self.removeAllView()
        let screenWidth = Double(UIScreen.main.bounds.width)
        let bannerHeight = screenWidth * Double(imgSize.height) / Double(imgSize.width)
        if isExpress {
            let size = CGSize(width: screenWidth, height: bannerHeight)
            let bannerAdView = BUNativeExpressBannerView(slotID: slotId, rootViewController: vc, adSize: size, isSupportDeepLink: isSupportDeepLink)
            bannerAdView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
            bannerAdView.updateConstraints()
            self.contentView = bannerAdView
            self.container.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
            self.container.addSubview(bannerAdView)
            self.container.updateConstraints()
            bannerAdView.delegate = self
            bannerAdView.loadAdData()

        } else {
            let bannerAdView = BUBannerAdView(slotID: slotId, size: imgSize, rootViewController: vc)
            bannerAdView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
            bannerAdView.updateConstraints()
            self.contentView = bannerAdView
            self.container.frame = CGRect(x: 0, y: 0, width: screenWidth, height: bannerHeight)
            self.container.addSubview(bannerAdView)
            self.container.updateConstraints()
            bannerAdView.delegate = self
            bannerAdView.loadAdData()
        }
    }

    private func invoke(width: CGFloat, height: CGFloat) {
        var params = [String: Any?]()
        params["width"] = width
        params["height"] = height
        self.methodChannel.invokeMethod("update", arguments: params)
    }

    private func removeAllView() {
        self.container.subviews.forEach { $0.removeFromSuperview() }
    }
}

extension FLTBannerView: BUBannerAdViewDelegate {
    public func bannerAdView(_ bannerAdView: BUBannerAdView, didLoadFailWithError error: Error?) {
//        self.invoke(message: error?.localizedDescription)
        self.removeAllView()
        self.methodChannel.invokeMethod("remove", arguments: nil)
    }

    public func bannerAdViewDidLoad(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {
        let frame = bannerAdView.frame
        self.invoke(width: frame.width, height: frame.height)
    }

    public func bannerAdViewDidClick(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {}

    public func bannerAdView(_ bannerAdView: BUBannerAdView, dislikeWithReason filterwords: [BUDislikeWords]?) {
        self.removeAllView()
        self.methodChannel.invokeMethod("remove", arguments: nil)
    }

    public func bannerAdViewDidBecomVisible(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {}

    public func bannerAdViewDidCloseOtherController(_ bannerAdView: BUBannerAdView, interactionType: BUInteractionType) {}
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
}

extension FLTBannerView: BUNativeExpressBannerViewDelegate {
    public func nativeExpressBannerAdViewDidLoad(_ bannerAdView: BUNativeExpressBannerView) {
        let frame = bannerAdView.frame
        self.invoke(width: frame.width, height: frame.height)
    }

    public func nativeExpressBannerAdViewDidClick(_ bannerAdView: BUNativeExpressBannerView) {}

    public func nativeExpressBannerAdViewRenderSuccess(_ bannerAdView: BUNativeExpressBannerView) {}

    public func nativeExpressBannerAdViewWillBecomVisible(_ bannerAdView: BUNativeExpressBannerView) {}

    public func nativeExpressBannerAdViewRenderFail(_ bannerAdView: BUNativeExpressBannerView, error: Error?) {}

    public func nativeExpressBannerAdView(_ bannerAdView: BUNativeExpressBannerView, didLoadFailWithError error: Error?) {
//        invoke(code: err?.code ?? -1, message: error?.localizedDescription)
        self.removeAllView()
        self.methodChannel.invokeMethod("remove", arguments: nil)
    }

    public func nativeExpressBannerAdView(_ bannerAdView: BUNativeExpressBannerView, dislikeWithReason filterwords: [BUDislikeWords]?) {
        self.removeAllView()
        self.methodChannel.invokeMethod("remove", arguments: nil)
    }

    public func nativeExpressBannerAdViewDidCloseOtherController(_ bannerAdView: BUNativeExpressBannerView, interactionType: BUInteractionType) {}
}
