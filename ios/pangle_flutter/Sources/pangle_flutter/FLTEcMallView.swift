//
//  FLTEcMallView.swift
//  pangle_flutter
//

import BUAdSDK
import Flutter

public class FLTEcMallView: NSObject, FlutterPlatformView {
    private let container: EcMallView

    init(_ frame: CGRect, id: Int64, params: [String: Any?], messenger: FlutterBinaryMessenger) {
        let channelName = String(format: "nullptrx.github.io/pangle_ecmallview_%lld", id)
        let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
        container = EcMallView(frame: frame, params: params, methodChannel: methodChannel)
        super.init()
    }

    public func view() -> UIView {
        container
    }

    deinit {
        UIUtil.removeAllView(container)
    }
}

class EcMallView: UIView {
    private var methodChannel: FlutterMethodChannel?
    private var adManager: BUNativeAdsManager?
    private var relatedView: BUNativeAdRelatedView?

    init(frame: CGRect, params: [String: Any?], methodChannel: FlutterMethodChannel) {
        self.methodChannel = methodChannel
        super.init(frame: frame)
        methodChannel.setMethodCallHandler(handle(_:result:))
        loadEcMallAd(params: params)
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

    private func loadEcMallAd(params: [String: Any?]) {
        guard let slotId = params["slotId"] as? String, !slotId.isEmpty else { return }

        let width = (params["width"] as? Double).map { CGFloat($0) } ?? UIScreen.main.bounds.width
        let height = (params["height"] as? Double).map { CGFloat($0) } ?? UIScreen.main.bounds.height

        let slot = BUAdSlot()
        slot.id = slotId
        slot.adType = .feed
        slot.supportRenderControl = true
        slot.imgSize = BUSize(by: .feed690_388)

        let manager = BUNativeAdsManager(slot: slot)
        manager.adSize = CGSize(width: width, height: height)
        manager.delegate = self
        manager.nativeExpressAdViewDelegate = self
        adManager = manager
        manager.loadAdData(withCount: 1)
    }

    private func postMessage(_ method: String, arguments: [String: Any?] = [:]) {
        DispatchQueue.main.async { [weak self] in
            self?.methodChannel?.invokeMethod(method, arguments: arguments)
        }
    }
}

extension EcMallView: BUNativeAdsManagerDelegate {
    func nativeAdsManagerSuccess(toLoad adsManager: BUNativeAdsManager, nativeAds: [BUNativeAd]?) {
        var adView: UIView?
        for nativeAd in (nativeAds ?? []) {
            let related = BUNativeAdRelatedView()
            related.refreshData(nativeAd)
            if related.isECMallValid() {
                relatedView = related
                adView = related.ecMallView
                break
            }
        }
        if adView == nil {
            adView = BUNativeAdRelatedView.defaultECMallView()
        }
        guard let adView else { return }
        subviews.forEach { $0.removeFromSuperview() }
        adView.frame = bounds
        adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(adView)
        postMessage("onShow")
    }

    func nativeAdsManager(_ adsManager: BUNativeAdsManager, didFailWithError error: Error?) {
        let e = error as NSError?
        postMessage("onError", arguments: [
            "code": e?.code ?? -1,
            "message": e?.localizedDescription ?? "",
        ])
    }
}

extension EcMallView: BUNativeExpressAdViewDelegate {
    func nativeExpressAdViewDidClick(_ nativeExpressAdView: BUNativeExpressAdView) {
        postMessage("onClick")
    }

    func nativeExpressAdView(_ nativeExpressAdView: BUNativeExpressAdView,
                             dislikeWithReason filterWords: [BUDislikeWords]?) {
        postMessage("onDislike", arguments: [
            "option": filterWords?.first?.name ?? "",
            "enforce": false,
        ])
        subviews.forEach { $0.removeFromSuperview() }
    }
}
