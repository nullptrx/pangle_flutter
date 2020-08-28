//
//  FLTInterstitialAd.swift
//  pangle_flutter
//
//  Created by Jerry on 2020/8/13.
//

import BUAdSDK

internal final class FLTInterstitialAd: NSObject, BUInterstitialAdDelegate {
    typealias Success = (BUInterstitialAd) -> Void
    typealias Fail = (BUInterstitialAd, Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    func interstitialAdDidLoad(_ interstitialAd: BUInterstitialAd) {
        let vc = AppUtil.getVC()
        interstitialAd.show(fromRootViewController: vc)
    }
    
    func interstitialAd(_ interstitialAd: BUInterstitialAd, didFailWithError error: Error?) {
        self.fail?(interstitialAd, error)
    }
    
    func interstitialAdDidClose(_ interstitialAd: BUInterstitialAd) {
        self.success?(interstitialAd)
    }
}
