//
//  FLTInterstitialAd.swift
//  pangle_flutter
//
//  Created by Jerry on 2020/8/12.
//

import BUAdSDK
import Flutter

internal final class FLTInterstitialExpressAd: NSObject, BUNativeExpresInterstitialAdDelegate {
    typealias Success = () -> Void
    typealias Fail = (Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    func nativeExpresInterstitialAdRenderSuccess(_ interstitialAd: BUNativeExpressInterstitialAd) {
        let vc = AppUtil.getVC()
        interstitialAd.show(fromRootViewController: vc)
    }
    
    func nativeExpresInterstitialAd(_ interstitialAd: BUNativeExpressInterstitialAd, didFailWithError error: Error?) {
        self.fail?(error)
    }
    
    func nativeExpresInterstitialAdRenderFail(_ interstitialAd: BUNativeExpressInterstitialAd, error: Error?) {
        self.fail?(error)
    }
    
    func nativeExpresInterstitialAdDidClose(_ interstitialAd: BUNativeExpressInterstitialAd) {
        self.success?()
    }
}
