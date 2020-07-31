//
//  RewardedVideoAdImpl.swift
//  ttad
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

public class FLTRewardedVideoAd: NSObject, BURewardedVideoAdDelegate {
    private var result: FlutterResult?
    init(_ result: @escaping FlutterResult) {
        self.result = result
    }
    
    public func rewardedVideoAdDidLoad(_ rewardedVideoAd: BURewardedVideoAd) {
        print("rewardedVideoAdDidLoad")
    }
    
    public func rewardedVideoAdVideoDidLoad(_ rewardedVideoAd: BURewardedVideoAd) {
        print("rewardedVideoAdVideoDidLoad")
        let keyWindow = UIApplication.shared.windows.first
        rewardedVideoAd.show(fromRootViewController: keyWindow!.rootViewController!)
    }
    
    public func rewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: BURewardedVideoAd) {
        invoke(code: -1, message: "video error")
    }
    
    public func rewardedVideoAdDidClose(_ rewardedVideoAd: BURewardedVideoAd) {
        invoke()
    }
    
    public func rewardedVideoAd(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {
        invoke(code: -1, message: error?.localizedDescription)
    }
    
    public func rewardedVideoAdDidClick(_ rewardedVideoAd: BURewardedVideoAd) {}
    
    public func rewardedVideoAdWillClose(_ rewardedVideoAd: BURewardedVideoAd) {}
    
    public func rewardedVideoAdDidClickSkip(_ rewardedVideoAd: BURewardedVideoAd) {}
    
    public func rewardedVideoAdServerRewardDidSucceed(_ rewardedVideoAd: BURewardedVideoAd, verify: Bool) {}
    
    public func rewardedVideoAdDidPlayFinish(_ rewardedVideoAd: BURewardedVideoAd, didFailWithError error: Error?) {}
    
    public func rewardedVideoAdCallback(_ rewardedVideoAd: BURewardedVideoAd, with rewardedVideoAdType: BURewardedVideoAdType) {}
    
    public func invoke(code: Int = 0, message: String? = nil) {
        guard result != nil else {
            return
        }
        
        let params = NSMutableDictionary()
        params["code"] = code
        params["message"] = message
        result!(params)
        PangleAdManager.shared.loadRewardedVideoAdComplete()
    }
}
