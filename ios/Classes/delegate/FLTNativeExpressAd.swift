//
//  FLTNativeExpressAdViewDelegate.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

internal final class FLTNativeExpressAdViewDelegate: NSObject, BUNativeExpressAdViewDelegate {
    typealias Success = ([String]) -> Void
    typealias Fail = (Error?) -> Void

    let success: Success?
    let fail: Fail?

    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }

    public func nativeExpressAdSuccess(toLoad nativeExpressAd: BUNativeExpressAdManager, views: [BUNativeExpressAdView]) {
        /// 设置view的关联对象，让delegate随着view的销毁一起销毁
        views.forEach {
            $0.extraDelegate = self
            $0.extraManager = nativeExpressAd
        }
        /// 存入缓存
        PangleAdManager.shared.setExpressAd(views)
        success?(views.map {
            String($0.hash)
        })
    }

    public func nativeExpressAdFail(toLoad nativeExpressAd: BUNativeExpressAdManager, error: Error?) {
        fail?(error)
    }

    public func nativeExpressAdViewRenderFail(_ nativeExpressAdView: BUNativeExpressAdView, error: Error?) {
        postMessage(nativeExpressAdView, "onRenderFail")
    }

    func nativeExpressAdViewRenderSuccess(_ nativeExpressAdView: BUNativeExpressAdView) {
        postMessage(nativeExpressAdView, "onRenderSuccess")
    }

    public func nativeExpressAdView(_ nativeExpressAdView: BUNativeExpressAdView, dislikeWithReason filterWords: [BUDislikeWords]) {
        postMessage(nativeExpressAdView, "onDislike", arguments: ["option": filterWords.first?.name ?? "", "enforce": false])
    }

    func nativeExpressAdViewDidClick(_ nativeExpressAdView: BUNativeExpressAdView) {
        postMessage(nativeExpressAdView, "onClick")
    }

    func nativeExpressAdViewWillShow(_ nativeExpressAdView: BUNativeExpressAdView) {
        postMessage(nativeExpressAdView, "onShow")
    }

    private func postMessage(_ nativeExpressAdView: BUNativeExpressAdView, _ method: String, arguments: [String: Any?] = [:]) {
        let channel = nativeExpressAdView.extraChannel
        channel?.invokeMethod(method, arguments: arguments)
    }
}

private var managerKey = "nullptrx.github.io/manager"
private var delegateKey = "nullptrx.github.io/delegate"
private var channelKey = "nullptrx.github.io/channel"

extension BUNativeExpressAdView {
    var extraManager: BUNativeExpressAdManager? {
        get {
            objc_getAssociatedObject(self, &managerKey) as? BUNativeExpressAdManager
        }
        set {
            objc_setAssociatedObject(self, &managerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var extraDelegate: BUNativeExpressAdViewDelegate? {
        get {
            objc_getAssociatedObject(self, &delegateKey) as? BUNativeExpressAdViewDelegate
        }
        set {
            objc_setAssociatedObject(self, &delegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    weak var extraChannel: FlutterMethodChannel? {
        get {
            objc_getAssociatedObject(self, &channelKey) as? FlutterMethodChannel
        }
        set {
            objc_setAssociatedObject(self, &channelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
