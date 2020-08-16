//
//  FLTInterstitialAd.swift
//  pangle_flutter
//
//  Created by Jerry on 2020/8/12.
//

import BUAdSDK
import Flutter

internal final class FLTInterstitialExpressAd: NSObject, BUNativeExpresInterstitialAdDelegate {
    typealias Success = (BUNativeExpressInterstitialAd) -> Void
    typealias Fail = (BUNativeExpressInterstitialAd, Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    func nativeExpresInterstitialAdRenderSuccess(_ interstitialAd: BUNativeExpressInterstitialAd) {
        let vc = AppUtil.getVC()
        interstitialAd.show(fromRootViewController: vc)
        self.success?(interstitialAd)
    }
    
    func nativeExpresInterstitialAd(_ interstitialAd: BUNativeExpressInterstitialAd, didFailWithError error: Error?) {
        self.fail?(interstitialAd, error)
    }
    
    func nativeExpresInterstitialAdRenderFail(_ interstitialAd: BUNativeExpressInterstitialAd, error: Error?) {
        self.fail?(interstitialAd, error)
    }
}
