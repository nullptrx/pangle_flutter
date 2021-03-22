//
//  FLTRewardedVideoExpressAd.swift
//  ttad
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTRewardedVideoExpressAd: NSObject, BUNativeExpressRewardedVideoAdDelegate {
    typealias Success = (Bool) -> Void
    typealias Fail = (Error?) -> Void

    private var verify = false
//    private var isSkipped = false
    private var loadingType: LoadingType
    private var slotId: String

    let success: Success?
    let fail: Fail?

    init(_ slotId: String, _ loadingType: LoadingType, success: Success?, fail: Fail?) {
        self.slotId = slotId
        self.loadingType = loadingType
        self.success = success
        self.fail = fail
    }

    func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        let preload = loadingType == .preload || loadingType == .preload_only
        if preload {
            rewardedVideoAd.extraDelegate = self
            /// 存入缓存
            PangleAdManager.shared.setRewardedVideoAd(slotId, rewardedVideoAd)
            /// 必须回调，否则task不能销毁，导致内存泄漏
            self.success?(false)
        } else {
            let vc = AppUtil.getVC()
            rewardedVideoAd.show(fromRootViewController: vc)
        }
    }

    func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
//        if self.isSkipped {
//            return
//        }
        if rewardedVideoAd.didReceiveSuccess != nil {
            rewardedVideoAd.didReceiveSuccess?(self.verify)
        } else {
            self.success?(self.verify)
        }
    }

    func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
        if rewardedVideoAd.didReceiveFail != nil {
            rewardedVideoAd.didReceiveFail?(error)
        } else {
            self.fail?(error)
        }
    }

    func nativeExpressRewardedVideoAdDidClickSkip(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
//        self.isSkipped = true
//        let error = NSError(domain: "skip", code: -1, userInfo: nil)
//        if rewardedVideoAd.didReceiveFail != nil {
//            rewardedVideoAd.didReceiveFail?(error)
//        } else {
//            self.fail?(error)
//        }
    }

    func nativeExpressRewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        let error = NSError(domain: "verify_fail", code: -1, userInfo: nil)
        if rewardedVideoAd.didReceiveFail != nil {
            rewardedVideoAd.didReceiveFail?(error)
        } else {
            self.fail?(error)
        }
    }

    func nativeExpressRewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, verify: Bool) {
        /// handle in close
        self.verify = verify
    }

    func nativeExpressRewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
    }
}

private var delegateKey = "nullptrx.github.io/delegate"
private var successKey = "nullptrx.github.io/delegate_success"
private var failKey = "nullptrx.github.io/delegate_fail"

extension BUNativeExpressRewardedVideoAd {
    var extraDelegate: BUNativeExpressRewardedVideoAdDelegate? {
        get {
            return objc_getAssociatedObject(self, &delegateKey) as? BUNativeExpressRewardedVideoAdDelegate
        }
        set {
            objc_setAssociatedObject(self, &delegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var didReceiveSuccess: ((Bool) -> Void)? {
        get {
            objc_getAssociatedObject(self, &successKey) as? ((Bool) -> Void)
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
