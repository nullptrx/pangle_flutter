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
    private var methodResult: FlutterResult?
    private let width: Float?
    private let height: Float?

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_bannerview_%lld", id)
        self.methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        self.container = UIView(frame: frame)

        self.width = params["width"] as? Float
        self.height = params["height"] as? Float

        super.init()

        self.methodChannel.setMethodCallHandler(self.handle(_:result:))

        self.loadAd(params)
    }

    public func view() -> UIView {
        return self.container
    }

    deinit {
        self.disposeView()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args: [String: Any?] = call.arguments as? [String: Any?] ?? [:]
        switch call.method {
        case "update":
            self.loadAd(args)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func loadAd(_ params: [String: Any?]) {
        let slotId = params["slotId"] as? String
        guard slotId != nil else {
            return
        }
        let imgSizeIndex = params["imgSize"] as! Int
        let imgSize = BUSize(by: BUProposalSize(rawValue: imgSizeIndex)!)!

        let isExpress = params["isExpress"] as? Bool ?? false
        let isSupportDeepLink = params["isSupportDeepLink"] as? Bool ?? true

        let width = imgSize.width
        let height = imgSize.height
        self.removeAllView()
        let screenWidth = UIScreen.main.bounds.width
        let bannerHeight = screenWidth * CGFloat(imgSize.height) / CGFloat(imgSize.width)

        let viewWidth: CGFloat
        let viewHeight: CGFloat
        if self.width != nil, self.height != nil {
            viewWidth = CGFloat(self.width!)
            viewHeight = CGFloat(self.height!)
        } else if self.width != nil {
            viewWidth = CGFloat(self.width!)
            viewHeight = viewWidth * CGFloat(height) / CGFloat(width)
        } else if self.height != nil {
            viewHeight = CGFloat(self.height!)
            viewWidth = viewHeight * CGFloat(width) / CGFloat(height)
        } else {
            viewWidth = screenWidth
            viewHeight = bannerHeight
        }

        self.container.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        self.container.updateConstraints()
        let vc = AppUtil.getVC()
        if isExpress {
            let size = CGSize(width: viewWidth, height: viewHeight)
            let bannerAdView = BUNativeExpressBannerView(slotID: slotId!, rootViewController: vc, adSize: size, isSupportDeepLink: isSupportDeepLink)
            bannerAdView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            bannerAdView.center = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
            self.container.addSubview(bannerAdView)
            bannerAdView.delegate = self
            bannerAdView.loadAdData()

        } else {
            let bannerAdView = BUBannerAdView(slotID: slotId!, size: imgSize, rootViewController: vc)
            bannerAdView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            bannerAdView.center = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
            self.container.addSubview(bannerAdView)

            bannerAdView.delegate = self
            bannerAdView.loadAdData()
        }
    }

    private func refreshUI(width: CGFloat, height: CGFloat) {
        var params = [String: Any?]()
        params["width"] = width
        params["height"] = height
        self.methodChannel.invokeMethod("update", arguments: params)
    }

    private func removeAllView() {
        self.container.subviews.forEach { $0.removeFromSuperview() }
    }

    private func disposeView() {
        self.removeAllView()
        self.methodChannel.invokeMethod("remove", arguments: nil)
        self.methodChannel.setMethodCallHandler(nil)
    }
}

extension FLTBannerView: BUBannerAdViewDelegate {
    public func bannerAdView(_ bannerAdView: BUBannerAdView, didLoadFailWithError error: Error?) {
        self.disposeView()
    }

    public func bannerAdViewDidLoad(_ bannerAdView: BUBannerAdView, withAdmodel nativeAd: BUNativeAd?) {
        let frame = bannerAdView.frame
        self.refreshUI(width: frame.width, height: frame.height)
    }

    public func bannerAdView(_ bannerAdView: BUBannerAdView, dislikeWithReason filterwords: [BUDislikeWords]?) {
        self.disposeView()
    }
}

extension FLTBannerView: BUNativeExpressBannerViewDelegate {
    public func nativeExpressBannerAdViewDidLoad(_ bannerAdView: BUNativeExpressBannerView) {
        let frame = bannerAdView.frame
        self.refreshUI(width: frame.width, height: frame.height)
    }

    public func nativeExpressBannerAdViewRenderFail(_ bannerAdView: BUNativeExpressBannerView, error: Error?) {
        self.disposeView()
    }

    public func nativeExpressBannerAdView(_ bannerAdView: BUNativeExpressBannerView, didLoadFailWithError error: Error?) {
//        invoke(code: err?.code ?? -1, message: error?.localizedDescription)
        self.disposeView()
    }

    public func nativeExpressBannerAdView(_ bannerAdView: BUNativeExpressBannerView, dislikeWithReason filterwords: [BUDislikeWords]?) {
        self.disposeView()
    }
}
