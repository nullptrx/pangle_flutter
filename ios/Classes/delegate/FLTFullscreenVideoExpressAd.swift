//
//  FLTFullscreenVideoExpressAd.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/25.
//

import Foundation

internal final class FLTFullscreenVideoExpressAd: NSObject, BUNativeExpressFullscreenVideoAdDelegate {
    typealias Success = (BUNativeExpressFullscreenVideoAd) -> Void
    typealias Fail = (BUNativeExpressFullscreenVideoAd, Error?) -> Void
    
    var preload: Bool
    
    let success: Success?
    let fail: Fail?
    
    init(_ preload: Bool, success: Success?, fail: Fail?) {
        self.preload = preload
        self.success = success
        self.fail = fail
    }
    
    func nativeExpressFullscreenVideoAdDidLoad(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        if self.preload {
            self.preload = false
            fullscreenVideoAd.extraDelegate = self
            self.success?(fullscreenVideoAd)
        } else {
            let vc = AppUtil.getVC()
            fullscreenVideoAd.show(fromRootViewController: vc)
        }
    }
    
    func nativeExpressFullscreenVideoAdDidClose(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        fullscreenVideoAd.didReceiveSuccess?()
        self.success?(fullscreenVideoAd)
    }
    
    func nativeExpressFullscreenVideoAdDidClickSkip(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {
        fullscreenVideoAd.didReceiveFail?(NSError(domain: "skipped", code: -1, userInfo: nil))
        self.fail?(fullscreenVideoAd, NSError(domain: "skipped", code: -1, userInfo: nil))
    }
    
    func nativeExpressFullscreenVideoAdViewRenderSuccess(_ rewardedVideoAd: BUNativeExpressFullscreenVideoAd) {}
    
    func nativeExpressFullscreenVideoAdDidDownLoadVideo(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd) {}
    
    func nativeExpressFullscreenVideoAdViewRenderFail(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd, error: Error?) {
        fullscreenVideoAd.didReceiveFail?(error)
        self.fail?(fullscreenVideoAd, error)
    }
    
    func nativeExpressFullscreenVideoAd(_ fullscreenVideoAd: BUNativeExpressFullscreenVideoAd, didFailWithError error: Error?) {
        fullscreenVideoAd.didReceiveFail?(error)
        self.fail?(fullscreenVideoAd, error)
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
        } set {
            objc_setAssociatedObject(self, &delegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var didReceiveSuccess: (() -> Void)? {
        get {
            objc_getAssociatedObject(self, &successKey) as? (() -> Void)
        } set {
            objc_setAssociatedObject(self, &successKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var didReceiveFail: ((Error?) -> Void)? {
        get {
            objc_getAssociatedObject(self, &failKey) as? ((Error?) -> Void)
        } set {
            objc_setAssociatedObject(self, &failKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
