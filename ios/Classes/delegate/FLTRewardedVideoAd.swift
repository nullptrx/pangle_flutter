//
//  FLTRewardedVideoAd.swift
//  ttad
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTRewardedVideoAd: NSObject, BURewardedVideoAdDelegate {
    typealias Success = (BURewardedVideoAd, Bool) -> Void
    typealias Fail = (BURewardedVideoAd, Error?) -> Void
    
    private var verify = false
    
    let success: Success?
    let fail: Fail?
    var preload: Bool
    
    init(_ preload: Bool, success: Success?, fail: Fail?) {
        self.preload = preload
        self.success = success
        self.fail = fail
    }
    
    public func rewardedVideoAdVideoDidLoad(_ rewardedVideoAd: BURewardedVideoAd) {
        if self.preload {
            self.preload = false
            rewardedVideoAd.extraDelegate = self
            self.success?(rewardedVideoAd, false)
        } else {
            let vc = AppUtil.getVC()
            rewardedVideoAd.show(fromRootViewController: vc)
        }
    }
    
    public func rewardedVideoAdDidClose(_ rewardedVideoAd: BURewardedVideoAd) {
//        self.success?(rewardedVideoAd, false)
        rewardedVideoAd.didReceiveSuccess?(self.verify)
        self.success?(rewardedVideoAd, self.verify)
    }
    
    public func rewardedVideoAd(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {
        rewardedVideoAd.didReceiveFail?(error)
        self.fail?(rewardedVideoAd, error)
    }
    
    public func rewardedVideoAdDidClickSkip(_ rewardedVideoAd: BURewardedVideoAd) {
        rewardedVideoAd.didReceiveFail?(NSError(domain: "skipped", code: -1, userInfo: nil))
        self.fail?(rewardedVideoAd, NSError(domain: "skipped", code: -1, userInfo: nil))
    }
    
    public func rewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BURewardedVideoAd) {
        rewardedVideoAd.didReceiveFail?(NSError(domain: "verify_failed", code: -1, userInfo: nil))
        self.fail?(rewardedVideoAd, nil)
    }
    
    public func rewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BURewardedVideoAd, verify: Bool) {
        /// handle in close
        self.verify = verify
    }
    
    public func rewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {
        rewardedVideoAd.didReceiveFail?(error)
    }
}

private var delegateKey = "nullptrx.github.io/delegate"
private var successKey = "nullptrx.github.io/delegate_success"
private var failKey = "nullptrx.github.io/delegate_fail"
extension BURewardedVideoAd {
    var extraDelegate: BURewardedVideoAdDelegate? {
        get {
            return objc_getAssociatedObject(self, &delegateKey) as? BURewardedVideoAdDelegate
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
