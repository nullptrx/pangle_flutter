//
//  FLTNativeBannerView.swift
//  pangle_flutter
//

import BUAdSDK
import Flutter

public class FLTNativeBannerView: NSObject, FlutterPlatformView {
    private let container: NativeBannerView

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_nativebannerview_%lld", id)
        let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        container = NativeBannerView(frame: frame, params: params, methodChannel: methodChannel)
        super.init()
    }

    public func view() -> UIView {
        container
    }

    deinit {
        UIUtil.removeAllView(container)
    }
}

class NativeBannerView: UIView {
    private var methodChannel: FlutterMethodChannel?
    private var nativeAd: BUNativeAd?

    init(frame: CGRect, params: [String: Any?], methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
        super.init(frame: frame)
        methodChannel.setMethodCallHandler(handle(_:result:))
        loadNativeAd(params: params)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        methodChannel?.setMethodCallHandler(nil)
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterMethodNotImplemented)
    }

    private func loadNativeAd(params: [String: Any?]) {
        guard let slotId = params["slotId"] as? String, !slotId.isEmpty else { return }

        let sizeMap = params["size"] as? [String: Double]
        let screenSize = UIScreen.main.bounds.size
        let adWidth = sizeMap?["width"].map(CGFloat.init) ?? screenSize.width
        let adHeight = sizeMap?["height"].map(CGFloat.init) ?? (screenSize.width / 2.0)

        let imgSize = BUSize()
        imgSize.imageWidth = 600
        imgSize.imageHeight = 257

        let slot = BUAdSlot()
        slot.id = slotId
        slot.AdType = .banner
        slot.imgSize = imgSize
        slot.supportRenderControl = true
        slot.adSize = CGSize(width: adWidth, height: adHeight)

        let ad = BUNativeAd(slot: slot)
        ad.rootViewController = AppUtil.getVC()
        ad.delegate = self
        nativeAd = ad
        ad.loadAdData()
    }

    private func postMessage(_ method: String, arguments: [String: Any?] = [:]) {
        DispatchQueue.main.async { [weak self] in
            self?.methodChannel?.invokeMethod(method, arguments: arguments)
        }
    }
}

extension NativeBannerView: BUNativeAdDelegate {
    func nativeAdDidLoad(_ nativeAd: BUNativeAd, view: UIView?) {
        guard let adView = view else { return }
        subviews.forEach { $0.removeFromSuperview() }
        adView.frame = bounds
        adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(adView)
        postMessage("onShow")
    }

    func nativeAd(_ nativeAd: BUNativeAd, didFailWithError error: Error?) {
        let e = error as NSError?
        postMessage("onError", arguments: [
            "code": e?.code ?? -1,
            "message": e?.localizedDescription ?? "",
        ])
    }

    func nativeAdDidClick(_ nativeAd: BUNativeAd, withView view: UIView?) {
        postMessage("onClick")
    }

    func nativeAdDidBecomeVisible(_ nativeAd: BUNativeAd) {
    }

    func nativeAd(_ nativeAd: BUNativeAd, dislikeWithReason filterWords: [BUDislikeWords]?) {
        postMessage("onDislike", arguments: [
            "option": filterWords?.first?.name ?? "",
            "enforce": false,
        ])
        subviews.forEach { $0.removeFromSuperview() }
    }

    func nativeAd(_ nativeAd: BUNativeAd, adContainerViewDidRemoved adContainerView: UIView) {
        subviews.forEach { $0.removeFromSuperview() }
    }
}
