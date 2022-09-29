//
//  FLTSplashExpressAd.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

internal final class FLTSplashExpressAd: NSObject, BUSplashAdDelegate {
   
    
    typealias Success = (String) -> Void
    typealias Fail = (Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    func nativeExpressSplashViewDidClick(_ splashAd: BUSplashAd) {
        self.success?("click")
        splashAd.removeSplashView()
    }
    
    func nativeExpressSplashViewDidClickSkip(_ splashAd: BUSplashAd) {
        self.success?("skip")
        splashAd.removeSplashView()
    }
    
    func nativeExpressSplashViewDidClose(_ splashAd: BUSplashAd) {
        self.success?("timeover")
        splashAd.removeSplashView()
    }
    
    func nativeExpressSplashView(_ splashAd: BUSplashAd, didFailWithError error: Error?) {
        self.fail?(error)
        splashAd.removeSplashView()
    }
    
    func nativeExpressSplashViewRenderFail(_ splashAd: BUSplashAd, error: Error?) {
        self.fail?(error)
        splashAd.removeSplashView()
    }
    
    func nativeExpressSplashViewDidLoad(_ splashAdView: BUSplashAd) {}
    
    func nativeExpressSplashViewRenderSuccess(_ splashAdView: BUSplashAd) {}
    
    func nativeExpressSplashViewWillVisible(_ splashAdView: BUSplashAd) {}
    
    func nativeExpressSplashViewCountdown(toZero splashAdView: BUSplashAd) {}
    
    func nativeExpressSplashViewFinishPlayDidPlayFinish(_ splashView: BUSplashAd, didFailWithError error: Error) {}
    
    func nativeExpressSplashViewDidCloseOtherController(_ splashView: BUSplashAd, interactionType: BUInteractionType) {}
    
    func splashAdLoadSuccess(_ splashAd: BUSplashAd) {
        
    }
    
    func splashAdLoadFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        self.fail?(error)
        splashAd.removeSplashView()
    }
    
    func splashAdRenderSuccess(_ splashAd: BUSplashAd) {
        
    }
    
    func splashAdRenderFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        
    }
    
    func splashAdWillShow(_ splashAd: BUSplashAd) {
        
    }
    
    func splashAdDidShow(_ splashAd: BUSplashAd) {
        
    }
    
    func splashAdDidClick(_ splashAd: BUSplashAd) {
        
    }
    
    func splashAdDidClose(_ splashAd: BUSplashAd, closeType: BUSplashAdCloseType) {
        
    }
    
    func splashAdViewControllerDidClose(_ splashAd: BUSplashAd) {
        
    }
    
    func splashDidCloseOtherController(_ splashAd: BUSplashAd, interactionType: BUInteractionType) {
        
    }
    
    func splashVideoAdDidPlayFinish(_ splashAd: BUSplashAd, didFailWithError error: Error) {
        
    }
}
