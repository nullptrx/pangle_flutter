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
    
    func nativeExpresInterstitialAdDidLoad(_ interstitialAd: BUNativeExpressInterstitialAd) {
        PangleEventStreamHandler.interstitial("load")
    }
    
    func nativeExpresInterstitialAdRenderSuccess(_ interstitialAd: BUNativeExpressInterstitialAd) {
        PangleEventStreamHandler.interstitial("render_success")
        let vc = AppUtil.getVC()
        interstitialAd.show(fromRootViewController: vc)
    }
    
    func nativeExpresInterstitialAd(_ interstitialAd: BUNativeExpressInterstitialAd, didFailWithError error: Error?) {
        PangleEventStreamHandler.interstitial("error")
        self.fail?(error)
    }
    
    func nativeExpresInterstitialAdRenderFail(_ interstitialAd: BUNativeExpressInterstitialAd, error: Error?) {
        PangleEventStreamHandler.interstitial("render_fail")
        self.fail?(error)
    }
    
    func nativeExpresInterstitialAdDidClose(_ interstitialAd: BUNativeExpressInterstitialAd) {
        PangleEventStreamHandler.interstitial("dismiss")
        self.success?()
    }
    
    func nativeExpresInterstitialAdWillVisible(_ interstitialAd: BUNativeExpressInterstitialAd) {
        PangleEventStreamHandler.interstitial("show")
    }
    
    func nativeExpresInterstitialAdDidClick(_ interstitialAd: BUNativeExpressInterstitialAd) {
        PangleEventStreamHandler.interstitial("click")
    }
    
    
    func nativeExpresInterstitialAdDidCloseOtherController(_ interstitialAd: BUNativeExpressInterstitialAd, interactionType: BUInteractionType) {
        
    }
}
