//
//  FLTRewardedVideoExpressAd.swift
//  ttad
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTRewardedVideoExpressAd: NSObject, BUNativeExpressRewardedVideoAdDelegate {
    typealias Success = (BUNativeExpressRewardedVideoAd, Bool) -> Void
    typealias Fail = (BUNativeExpressRewardedVideoAd, Error?) -> Void
    
    private var verify = false
    
    var preload: Bool
    
    let success: Success?
    let fail: Fail?
    
    init(_ preload: Bool, success: Success?, fail: Fail?) {
        self.preload = preload
        self.success = success
        self.fail = fail
    }
    
    func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        if self.preload {
            self.preload = false
            rewardedVideoAd.extraDelegate = self
            self.success?(rewardedVideoAd, false)
        } else {
            let vc = AppUtil.getVC()
            rewardedVideoAd.show(fromRootViewController: vc)
        }
    }
    
    func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
//        self.success?(rewardedVideoAd, false)
        rewardedVideoAd.didReceiveSuccess?(self.verify)
        self.success?(rewardedVideoAd, self.verify)
    }
    
    func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
        rewardedVideoAd.didReceiveFail?(error)
        self.fail?(rewardedVideoAd, error)
    }
    
    func nativeExpressRewardedVideoAdDidClickSkip(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        rewardedVideoAd.didReceiveFail?(NSError(domain: "skipped", code: -1, userInfo: nil))
        self.fail?(rewardedVideoAd, NSError(domain: "skipped", code: -1, userInfo: nil))
    }
    
    func nativeExpressRewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        rewardedVideoAd.didReceiveFail?(NSError(domain: "verify_failed", code: -1, userInfo: nil))
        self.fail?(rewardedVideoAd, nil)
    }
    
    func nativeExpressRewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, verify: Bool) {
        /// handle in close
        self.verify = verify
    }
    
    func nativeExpressRewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {}
}

private var delegateKey = "nullptrx.github.io/delegate"
private var successKey = "nullptrx.github.io/delegate_success"
private var failKey = "nullptrx.github.io/delegate_fail"

extension BUNativeExpressRewardedVideoAd {
    var extraDelegate: BUNativeExpressRewardedVideoAdDelegate? {
        get {
            return objc_getAssociatedObject(self, &delegateKey) as? BUNativeExpressRewardedVideoAdDelegate
        } set {
            objc_setAssociatedObject(self, &delegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var didReceiveSuccess: ((Bool) -> Void)? {
        get {
            objc_getAssociatedObject(self, &successKey) as? ((Bool) -> Void)
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
