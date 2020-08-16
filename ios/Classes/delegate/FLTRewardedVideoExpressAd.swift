//
//  RewardedVideoAdImpl.swift
//  ttad
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTRewardedVideoExpressAd: NSObject, BUNativeExpressRewardedVideoAdDelegate {
    typealias Success = (BUNativeExpressRewardedVideoAd, Bool) -> Void
    typealias Fail = (BUNativeExpressRewardedVideoAd, Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    func nativeExpressRewardedVideoAdDidLoad(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        let vc = AppUtil.getVC()
        rewardedVideoAd.show(fromRootViewController: vc)
    }
    
    func nativeExpressRewardedVideoAdDidClose(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        self.success?(rewardedVideoAd, false)
    }
    
    func nativeExpressRewardedVideoAd(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
        self.fail?(rewardedVideoAd, error)
    }
    
    func nativeExpressRewardedVideoAdDidClickSkip(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        self.fail?(rewardedVideoAd, NSError(domain: "skipped", code: -1, userInfo: nil))
    }
    
    func nativeExpressRewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd) {
        self.fail?(rewardedVideoAd, nil)
    }
    
    func nativeExpressRewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, verify: Bool) {
        self.success?(rewardedVideoAd, verify)
    }
    
    func nativeExpressRewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BUNativeExpressRewardedVideoAd, didFailWithError error: Error?) {
//        self.success?(rewardedVideoAd, false)
    }
}
