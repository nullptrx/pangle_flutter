//
//  FLTSplashAd.swift
//  Pods-Runner
//
//  Created by Jerry on 2020/7/20.
//

import BUAdSDK
import Foundation

internal final class FLTSplashAd: NSObject, BUSplashAdDelegate {
    typealias Success = () -> Void
    typealias Fail = (Error?) -> Void
    
    let success: Success?
    let fail: Fail?
    
    init(success: Success?, fail: Fail?) {
        self.success = success
        self.fail = fail
    }
    
    public func splashAdDidClick(_ splashAd: BUSplashAdView) {
//        isClicked = true
    }
    
    func splashAdDidClickSkip(_ splashAd: BUSplashAdView) {
        splashAd.removeFromSuperview()
        self.success?()
    }
    
    public func splashAdDidClose(_ splashAd: BUSplashAdView) {
        splashAd.removeFromSuperview()
        self.success?()
    }
    
    public func splashAd(_ splashAd: BUSplashAdView, didFailWithError error: Error?) {
        splashAd.removeFromSuperview()
        self.fail?(error)
    }
}
