//
//  FLTSplashAd.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTSplashAd: NSObject, BUSplashAdDelegate {
    
    typealias Success = (String, Int) -> Void
    typealias Fail = (Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    func splashAdDidClick(_ splashAd: BUSplashAd) {
    }
    
    public func splashAdDidClose(_ splashAd: BUSplashAd) {
        
    }
    
    func splashAdDidClose(_ splashAd: BUSplashAd, closeType: BUSplashAdCloseType) {
        self.success?("close", closeType.rawValue)
        splashAd.removeSplashView()
    }
    
    func splashAdLoadSuccess(_ splashAd: BUSplashAd) {}
    
    func splashAdLoadFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        self.fail?(error)
        splashAd.removeSplashView()
    }
    
    func splashAdRenderSuccess(_ splashAd: BUSplashAd) {}
    
    func splashAdRenderFail(_ splashAd: BUSplashAd, error: BUAdError?) {
        self.fail?(error)
        splashAd.removeSplashView()
    }
    
    func splashAdWillShow(_ splashAd: BUSplashAd) {}
    
    func splashAdDidShow(_ splashAd: BUSplashAd) {
        
    }
    
    func splashAdViewControllerDidClose(_ splashAd: BUSplashAd) {
        
    }
    
    func splashDidCloseOtherController(_ splashAd: BUSplashAd, interactionType: BUInteractionType) {
        
    }
    
    func splashVideoAdDidPlayFinish(_ splashAd: BUSplashAd, didFailWithError error: Error) {
        
    }
}
