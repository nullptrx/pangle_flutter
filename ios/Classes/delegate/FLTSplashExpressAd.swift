//
//  FLTSplashExpressAd.swift
//  pangle_flutter
//
//  Created by nullptrX on 2020/8/16.
//

import BUAdSDK

internal final class FLTSplashExpressAd: NSObject, BUNativeExpressSplashViewDelegate {
    typealias Success = (String) -> Void
    typealias Fail = (Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    func nativeExpressSplashViewDidClick(_ splashAdView: BUNativeExpressSplashView) {
        self.success?("click")
        splashAdView.removeFromSuperview()
    }
    
    func nativeExpressSplashViewDidClickSkip(_ splashAdView: BUNativeExpressSplashView) {
        self.success?("skip")
        splashAdView.removeFromSuperview()
    }
    
    func nativeExpressSplashViewDidClose(_ splashAdView: BUNativeExpressSplashView) {
        self.success?("timeover")
        splashAdView.removeFromSuperview()
    }
    
    func nativeExpressSplashView(_ splashAdView: BUNativeExpressSplashView, didFailWithError error: Error?) {
        self.fail?(error)
        splashAdView.removeFromSuperview()
    }
    
    func nativeExpressSplashViewRenderFail(_ splashAdView: BUNativeExpressSplashView, error: Error?) {
        self.fail?(error)
        splashAdView.removeFromSuperview()
    }
    
    func nativeExpressSplashViewDidLoad(_ splashAdView: BUNativeExpressSplashView) {}
    
    func nativeExpressSplashViewRenderSuccess(_ splashAdView: BUNativeExpressSplashView) {}
    
    func nativeExpressSplashViewWillVisible(_ splashAdView: BUNativeExpressSplashView) {}
    
    func nativeExpressSplashViewCountdown(toZero splashAdView: BUNativeExpressSplashView) {}
    
    func nativeExpressSplashViewFinishPlayDidPlayFinish(_ splashView: BUNativeExpressSplashView, didFailWithError error: Error) {}
    
    func nativeExpressSplashViewDidCloseOtherController(_ splashView: BUNativeExpressSplashView, interactionType: BUInteractionType) {}
}
