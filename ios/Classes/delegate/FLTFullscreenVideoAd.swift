//
//  FLTFullscreenVideoAd.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/25.
//

import Foundation

internal final class FLTFullscreenVideoAd: NSObject, BUFullscreenVideoAdDelegate {
    typealias Success = (BUFullscreenVideoAd) -> Void
    typealias Fail = (BUFullscreenVideoAd, Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    var preload: Bool
    
    init(_ preload: Bool, success: Success?, fail: Fail?) {
        self.preload = preload
        self.success = success
        self.fail = fail
    }
    
    func fullscreenVideoAdVideoDataDidLoad(_ fullscreenVideoAd: BUFullscreenVideoAd) {
        if self.preload {
            self.preload = false
            fullscreenVideoAd.extraDelegate = self
            self.success?(fullscreenVideoAd)
        } else {
            let vc = AppUtil.getVC()
            fullscreenVideoAd.show(fromRootViewController: vc)
        }
    }
    
    func fullscreenVideoAdDidClose(_ fullscreenVideoAd: BUFullscreenVideoAd) {
        fullscreenVideoAd.didReceiveSuccess?()
        self.success?(fullscreenVideoAd)
    }
    
    func fullscreenVideoAdDidClickSkip(_ fullscreenVideoAd: BUFullscreenVideoAd) {
        fullscreenVideoAd.didReceiveFail?(NSError(domain: "skipped", code: -1, userInfo: nil))
        self.fail?(fullscreenVideoAd, NSError(domain: "skipped", code: -1, userInfo: nil))
    }
    
    func fullscreenVideoAd(_ fullscreenVideoAd: BUFullscreenVideoAd, didFailWithError error: Error?) {
        fullscreenVideoAd.didReceiveFail?(error)
        self.fail?(fullscreenVideoAd, error)
    }
    
    func fullscreenVideoAdDidPlayFinish(_ fullscreenVideoAd: BUFullscreenVideoAd, didFailWithError error: Error?) {
        fullscreenVideoAd.didReceiveFail?(error)
    }
}

private var delegateKey = "nullptrx.github.io/delegate"
private var successKey = "nullptrx.github.io/delegate_success"
private var failKey = "nullptrx.github.io/delegate_fail"

extension BUFullscreenVideoAd {
    var extraDelegate: BUFullscreenVideoAdDelegate? {
        get {
            return objc_getAssociatedObject(self, &delegateKey) as? BUFullscreenVideoAdDelegate
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
