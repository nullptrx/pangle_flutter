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
    private var methodResult: FlutterResult?
    private let uiGesture = BannerTouchGesture()
    private var isUserInteractionEnabled = true
    private weak var bannerView: BUNativeExpressBannerView?

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_bannerview_%lld", id)
        self.methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        self.container = BannerView(frame: frame)

        super.init()

        let gesture = UITapGestureRecognizer()
        gesture.delegate = self.uiGesture
        self.container.addGestureRecognizer(gesture)

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
        case "remove":
            self.onlyRemoveView()
        case "setUserInteractionEnabled":
            let enable: Bool = call.arguments as? Bool ?? false
            self.bannerView?.isUserInteractionEnabled = enable
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
        let isUserInteractionEnabled = params["isUserInteractionEnabled"] as? Bool ?? true

        self.isUserInteractionEnabled = isUserInteractionEnabled
        let viewWidth: Double
        let viewHeight: Double
        self.onlyRemoveView()

        let vc = AppUtil.getVC()
        if isExpress {
            let expressArgs: [String: Double] = params["expressSize"] as! [String: Double]
            let width = expressArgs["width"]!
            let height = expressArgs["height"]!
            let adSize = CGSize(width: width, height: height)

            viewWidth = width
            viewHeight = height

            let bannerAdView = BUNativeExpressBannerView(slotID: slotId!, rootViewController: vc, adSize: adSize, isSupportDeepLink: isSupportDeepLink)
            bannerAdView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            bannerAdView.center = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
            self.container.addSubview(bannerAdView)
            bannerAdView.delegate = self
            bannerAdView.loadAdData()
            self.bannerView = bannerAdView

        } else {
            viewWidth = Double(UIScreen.main.bounds.width)
            viewHeight = viewWidth * Double(imgSize.height) / Double(imgSize.width)

            let bannerAdView = BUBannerAdView(slotID: slotId!, size: imgSize, rootViewController: vc)

            bannerAdView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            bannerAdView.center = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
            self.container.addSubview(bannerAdView)

            bannerAdView.delegate = self
            bannerAdView.loadAdData()
        }
        self.container.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        self.container.updateConstraints()
    }

    private func refreshUI(width: CGFloat, height: CGFloat) {
        var params = [String: Any?]()
        params["width"] = width
        params["height"] = height
        self.methodChannel.invokeMethod("update", arguments: params)
    }

    private func onlyRemoveView() {
        self.container.subviews.forEach {
            if $0 is BUNativeExpressBannerView {
                let v = $0 as! BUNativeExpressBannerView
                v.delegate = nil
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
            $0.subviews.forEach { $0.removeFromSuperview() }

            $0.removeFromSuperview()
        }
    }

    private func disposeView() {
        self.onlyRemoveView()
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

    public func nativeExpressBannerAdViewRenderSuccess(_ bannerAdView: BUNativeExpressBannerView) {
        bannerAdView.isUserInteractionEnabled = self.isUserInteractionEnabled
    }
}

class BannerView: UIView {
}

private class BannerTouchGesture: NSObject, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is BannerView {
            return true
        }
        return false
    }
}
