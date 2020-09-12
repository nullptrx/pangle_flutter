//
//  FLTNativeExpressAdViewDelegate.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

internal final class FLTNativeExpressAdViewDelegate: NSObject, BUNativeExpressAdViewDelegate {
    typealias Success = ([BUNativeExpressAdView]) -> Void
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
            $0.delegate = self
            $0.manager = nativeExpressAd
        }
        /// 存入缓存
        PangleAdManager.shared.setExpressAd(views)
        self.success?(views)
    }

    public func nativeExpressAdFail(toLoad nativeExpressAd: BUNativeExpressAdManager, error: Error?) {
        self.fail?(error)
    }

    public func nativeExpressAdViewRenderFail(_ nativeExpressAdView: BUNativeExpressAdView, error: Error?) {
        nativeExpressAdView.didReceiveRenderFail?(nativeExpressAdView, error)
    }

    func nativeExpressAdViewRenderSuccess(_ nativeExpressAdView: BUNativeExpressAdView) {
        nativeExpressAdView.didReceiveRenderSuccess?(nativeExpressAdView)
    }

    public func nativeExpressAdView(_ nativeExpressAdView: BUNativeExpressAdView, dislikeWithReason filterWords: [BUDislikeWords]) {
        nativeExpressAdView.didReceiveDislike?(nativeExpressAdView, filterWords)
    }
}

private var managerKey = "nullptrx.github.io/manager"
private var delegateKey = "nullptrx.github.io/delegate"
private var dislikeDelegateKey = "nullptrx.github.io/delegate_dislike"
private var renderSuccessDelegateKey = "nullptrx.github.io/delegate_render_success"
private var renderFailDelegateKey = "nullptrx.github.io/delegate_render_fail"

extension BUNativeExpressAdView {
    var manager: BUNativeExpressAdManager? {
        get {
            return objc_getAssociatedObject(self, &managerKey) as? BUNativeExpressAdManager
        } set {
            objc_setAssociatedObject(self, &managerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var delegate: BUNativeExpressAdViewDelegate? {
        get {
            return objc_getAssociatedObject(self, &delegateKey) as? BUNativeExpressAdViewDelegate
        } set {
            objc_setAssociatedObject(self, &delegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 设置dislike的点击事件
    var didReceiveDislike: ((BUNativeExpressAdView, [BUDislikeWords]) -> Void)? {
        get {
            objc_getAssociatedObject(self, &dislikeDelegateKey) as? ((BUNativeExpressAdView, [BUDislikeWords]) -> Void)
        } set {
            objc_setAssociatedObject(self, &dislikeDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var didReceiveRenderFail: ((BUNativeExpressAdView, Error?) -> Void)? {
        get {
            objc_getAssociatedObject(self, &renderFailDelegateKey) as? ((BUNativeExpressAdView, Error?) -> Void)
        } set {
            objc_setAssociatedObject(self, &renderFailDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var didReceiveRenderSuccess: ((BUNativeExpressAdView) -> Void)? {
        get {
            objc_getAssociatedObject(self, &renderSuccessDelegateKey) as? ((BUNativeExpressAdView) -> Void)
        } set {
            objc_setAssociatedObject(self, &renderSuccessDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
