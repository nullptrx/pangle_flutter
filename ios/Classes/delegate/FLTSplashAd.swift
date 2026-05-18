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
    weak var rootViewController: UIViewController?

    init(success: Success?, fail: Fail?, rootViewController: UIViewController?) {
        self.success = success
        self.fail = fail
        self.rootViewController = rootViewController
    }
    
    func splashAdDidClick(_ splashAd: BUSplashAd) {
    }
    
    public func splashAdDidClose(_ splashAd: BUSplashAd) {
        
    }
    
    func splashAdDidClose(_ splashAd: BUSplashAd, closeType: BUSplashAdCloseType) {
        self.success?("close", closeType.rawValue)
        splashAd.removeSplashView()
    }
    
    func splashAdLoadSuccess(_ splashAd: BUSplashAd) {
        // 新版 SDK 7.x 要求在加载成功后再调用 showSplashView
        if let vc = rootViewController {
            splashAd.showSplashView(inRootViewController: vc)
        }
    }
    
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
    
    func splashVideoAdDidPlayFinish(_ splashAd: BUSplashAd, didFailWithError error: Error?) {
        
    }
}
