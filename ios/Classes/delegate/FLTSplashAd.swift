//
//  FLTSplashAd.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTSplashAd: NSObject, BUSplashAdDelegate {
    func splashAdDidClose(_ splashAd: BUSplashAd, closeType: BUSplashAdCloseType) {
        
    }
    
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
    
    func splashAdViewControllerDidClose(_ splashAd: BUSplashAd) {
        
    }
    
    func splashDidCloseOtherController(_ splashAd: BUSplashAd, interactionType: BUInteractionType) {
        
    }
    
    func splashVideoAdDidPlayFinish(_ splashAd: BUSplashAd, didFailWithError error: Error) {
        
    }
    
    typealias Success = (String) -> Void
    typealias Fail = (Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    public func splashAdDidClick(_ splashAd: BUSplashAd) {
        self.success?("click")
        splashAd.removeSplashView()
    }
    
    func splashAdDidClickSkip(_ splashAd: BUSplashAd) {
        self.success?("skip")
        splashAd.removeSplashView()
    }
    
    public func splashAdDidClose(_ splashAd: BUSplashAd) {
        self.success?("timeover")
        splashAd.removeSplashView()
    }
    

}
