//
//  RewardedVideoAdImpl.swift
//  ttad
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTRewardedVideoAd: NSObject, BURewardedVideoAdDelegate {
    typealias Success = (BURewardedVideoAd, Bool) -> Void
    typealias Fail = (BURewardedVideoAd, Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    public func rewardedVideoAdVideoDidLoad(_ rewardedVideoAd: BURewardedVideoAd) {
        let vc = AppUtil.getVC()
        rewardedVideoAd.show(fromRootViewController: vc)
    }
    
    public func rewardedVideoAdDidClose(_ rewardedVideoAd: BURewardedVideoAd) {
        self.success?(rewardedVideoAd, false)
    }
    
    public func rewardedVideoAd(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {
        self.fail?(rewardedVideoAd, error)
    }
    
    public func rewardedVideoAdDidClickSkip(_ rewardedVideoAd: BURewardedVideoAd) {
        self.fail?(rewardedVideoAd, NSError(domain: "skipped", code: -1, userInfo: nil))
    }
    
    public func rewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BURewardedVideoAd) {
        self.fail?(rewardedVideoAd, nil)
    }
    
    public func rewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BURewardedVideoAd, verify: Bool) {
        self.success?(rewardedVideoAd, verify)
    }
    
    public func rewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {}
}
