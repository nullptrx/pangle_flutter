//
//  FLTRewardedVideoAd.swift
//  ttad
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTRewardedVideoAd: NSObject, BURewardedVideoAdDelegate {
    typealias Success = (Bool) -> Void
    typealias Fail = (Error?) -> Void
    
    private var verify = false
//    private var isSkipped = false
    
    let success: Success?
    let fail: Fail?
    private var loadingType: LoadingType
    
    init(_ loadingType: LoadingType, success: Success?, fail: Fail?) {
        self.loadingType = loadingType
        self.success = success
        self.fail = fail
    }
    
    public func rewardedVideoAdVideoDidLoad(_ rewardedVideoAd: BURewardedVideoAd) {
        let preload = self.loadingType == .preload || self.loadingType == .preload_only
        if preload {
            rewardedVideoAd.extraDelegate = self
            /// 存入缓存
            PangleAdManager.shared.setRewardedVideoAd(rewardedVideoAd)
            /// 必须回调，否则task不能销毁，导致内存泄漏
            self.success?(false)
        } else {
            let vc = AppUtil.getVC()
            rewardedVideoAd.show(fromRootViewController: vc)
        }
    }
    
    public func rewardedVideoAdDidClose(_ rewardedVideoAd: BURewardedVideoAd) {
//        if self.isSkipped {
//            return
//        }
        if rewardedVideoAd.didReceiveSuccess != nil {
            rewardedVideoAd.didReceiveSuccess?(self.verify)
        } else {
            self.success?(self.verify)
        }
    }
    
    public func rewardedVideoAd(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {
        if rewardedVideoAd.didReceiveFail != nil {
            rewardedVideoAd.didReceiveFail?(error)
        } else {
            self.fail?(error)
        }
    }
    
    public func rewardedVideoAdDidClickSkip(_ rewardedVideoAd: BURewardedVideoAd) {
//        self.isSkipped = true
//        let error = NSError(domain: "skip", code: -1, userInfo: nil)
//        if rewardedVideoAd.didReceiveFail != nil {
//            rewardedVideoAd.didReceiveFail?(error)
//        } else {
//            self.fail?(error)
//        }
    }
    
    public func rewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BURewardedVideoAd) {
        let error = NSError(domain: "verify_fail", code: -1, userInfo: nil)
        if rewardedVideoAd.didReceiveFail != nil {
            rewardedVideoAd.didReceiveFail?(error)
        } else {
            self.fail?(error)
        }
    }
    
    public func rewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BURewardedVideoAd, verify: Bool) {
        /// handle in close
        self.verify = verify
    }
    
    public func rewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {}
    
}

private var delegateKey = "nullptrx.github.io/delegate"
private var successKey = "nullptrx.github.io/delegate_success"
private var failKey = "nullptrx.github.io/delegate_fail"
extension BURewardedVideoAd {
    unowned var extraDelegate: BURewardedVideoAdDelegate? {
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
