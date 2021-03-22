//
//  FLTFullscreenVideoExpressAd.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/25.
//

import BUAdSDK
import Foundation

internal final class FLTFullscreenVideoExpressAd: NSObject, BUNativeExpressFullscreenVideoAdDelegate {
    typealias Success = () -> Void
    typealias Fail = (Error?) -> Void

    private var isSkipped = false
    private var loadingType: LoadingType
    private var slotId: String

    let success: Success?
    let fail: Fail?

    init(_ slotId: String, loadingType: LoadingType, success: Success?, fail: Fail?) {
        self.loadingType = loadingType
        self.slotId = slotId
        self.success = success
        self.fail = fail
    }

    func nativeExpressFullscreenVideoAdDidLoad(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        let preload = self.loadingType == .preload || self.loadingType == .preload_only
        if preload {
            self.loadingType = .normal
            fullscreenVideoAd.extraDelegate = self
            /// 存入缓存
            PangleAdManager.shared.setFullScreenVideoAd(slotId, fullscreenVideoAd)
            /// 必须回调，否则task不能销毁，导致内存泄漏
            self.success?()
        } else {
            let vc = AppUtil.getVC()
            fullscreenVideoAd.show(fromRootViewController: vc)
        }
    }

    func nativeExpressFullscreenVideoAdDidClose(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        if self.isSkipped {
            return
        }
        if fullscreenVideoAd.didReceiveSuccess != nil {
            fullscreenVideoAd.didReceiveSuccess?()
        } else {
            self.success?()
        }
    }

    func nativeExpressFullscreenVideoAdDidClickSkip(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        self.isSkipped = true
        let error = NSError(domain: "skip", code: -1, userInfo: nil)
        if fullscreenVideoAd.didReceiveFail != nil {
            fullscreenVideoAd.didReceiveFail?(error)
        } else {
            self.fail?(error)
        }
    }

    func nativeExpressFullscreenVideoAdViewRenderSuccess(_ rewardedVideoAd: BUNativeExpressFullscreenVideoAd) {
    }

    func nativeExpressFullscreenVideoAdDidDownLoadVideo(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
    }

    func nativeExpressFullscreenVideoAdViewRenderFail(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd, error: Error?) {
        if fullscreenVideoAd.didReceiveFail != nil {
            fullscreenVideoAd.didReceiveFail?(error)
        } else {
            self.fail?(error)
        }
    }

    func nativeExpressFullscreenVideoAd(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd, didFailWithError error: Error?) {
        if fullscreenVideoAd.didReceiveFail != nil {
            fullscreenVideoAd.didReceiveFail?(error)
        } else {
            self.fail?(error)
        }
    }

    func nativeExpressFullscreenVideoAdDidPlayFinish(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd, didFailWithError error: Error?) {
    }

}

private var delegateKey = "nullptrx.github.io/delegate"
private var successKey = "nullptrx.github.io/delegate_success"
private var failKey = "nullptrx.github.io/delegate_fail"

extension BUNativeExpressFullscreenVideoAd {
    var extraDelegate: BUNativeExpressFullscreenVideoAdDelegate? {
        get {
            return objc_getAssociatedObject(self, &delegateKey) as? BUNativeExpressFullscreenVideoAdDelegate
        }
        set {
            objc_setAssociatedObject(self, &delegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var didReceiveSuccess: (() -> Void)? {
        get {
            objc_getAssociatedObject(self, &successKey) as? (() -> Void)
        }
        set {
            objc_setAssociatedObject(self, &successKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var didReceiveFail: ((Error?) -> Void)? {
        get {
            objc_getAssociatedObject(self, &failKey) as? ((Error?) -> Void)
        }
        set {
            objc_setAssociatedObject(self, &failKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
